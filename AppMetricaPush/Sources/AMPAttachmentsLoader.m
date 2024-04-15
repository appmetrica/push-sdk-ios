
#import "AMPAttachmentsLoader.h"

#import "AMPAttachmentPayload.h"
#import "AMPLibraryAnalyticsTracker.h"

#import <UserNotifications/UserNotifications.h>

@interface AMPAttachmentsLoader ()

@property (nonatomic, copy, readonly) NSArray<AMPAttachmentPayload *> *attachments;
@property (nonatomic, strong, readonly) NSURLSession *urlSession;
@property (nonatomic, strong, readonly) NSFileManager *fileManager;
@property (nonatomic, strong, readonly) AMPLibraryAnalyticsTracker *tracker;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSURLSessionTask *> *tasks;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSURL *, NSURL *> *downloadedFiles;
@property (nonatomic, copy) AMPAttachmentsLoaderCallback callback;
@property (nonatomic, assign) BOOL complete;

@end

@implementation AMPAttachmentsLoader

- (instancetype)initWithAttachments:(NSArray<AMPAttachmentPayload *> *)attachments
{
    return [self initWithAttachments:attachments
                          urlSession:[NSURLSession sharedSession]
                         fileManager:[NSFileManager defaultManager]
                             tracker:[AMPLibraryAnalyticsTracker sharedInstance]];
}

- (instancetype)initWithAttachments:(NSArray<AMPAttachmentPayload *> *)attachments
                         urlSession:(NSURLSession *)urlSession
                        fileManager:(NSFileManager *)fileManager
                            tracker:(AMPLibraryAnalyticsTracker *)tracker
{
    self = [super init];
    if (self != nil) {
        _attachments = [attachments copy];
        _urlSession = urlSession;
        _fileManager = fileManager;
        _tracker = tracker;

        _tasks = [NSMutableDictionary dictionary];
        _downloadedFiles = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)downloadWithCallback:(AMPAttachmentsLoaderCallback)callback
{
    self.callback = callback;
    if (self.attachments.count == 0) {
        [self completeWithAttachments:@[] error:nil];
        return;
    }

    for (AMPAttachmentPayload *payload in self.attachments) {
        if (self.tasks[payload.url] == nil) {
            [self startDownloadTaskWithURL:payload.url];
        }
    }
}

- (void)startDownloadTaskWithURL:(NSURL *)url
{
    __weak __typeof(self) weakSelf = self;
    NSURLSessionTask *__block task =
        [self.urlSession downloadTaskWithURL:url
                           completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                               [weakSelf processDownloadCompletionForURL:url
                                                                location:location
                                                                response:response
                                                                   error:error];
                           }];
    @synchronized (self) {
        self.tasks[url] = task;
    }
    [task resume];
}

- (void)processDownloadCompletionForURL:(NSURL *)url
                               location:(NSURL *)location
                               response:(NSURLResponse *)response
                                  error:(NSError *)error
{
    if (self.complete) {
        return;
    }

    if (error != nil) {
        [self.tracker reportAttachmentDownloadError:error stage:@"network"];
        [self completeDownloadSourceURL:url withError:error];
        return;
    }

    NSError *internalError = nil;
    if ([self verifyResponse:response error:&internalError] == NO) {
        [self.tracker reportAttachmentDownloadError:internalError stage:@"http_status"];
        [self completeDownloadSourceURL:url withError:internalError];
        return;
    }

    NSURL *tempFileURL = [self tempFileURLWithExtension:[url pathExtension]];
    if ([self.fileManager moveItemAtURL:location toURL:tempFileURL error:&internalError] == NO) {
        [self.tracker reportAttachmentDownloadError:internalError stage:@"file_move"];
        [self completeDownloadSourceURL:url withError:internalError];
        return;
    }

    [self completeDownloadSourceURL:url fileURL:tempFileURL];
}

- (BOOL)verifyResponse:(NSURLResponse *)response error:(NSError **)error
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == NO) {
        return YES;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSError *internalError = nil;

    if (httpResponse.statusCode != 200) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"HTTP response status is not 200.",
            @"NSHTTPURLResponseStatusCode": @(httpResponse.statusCode),
        };
        internalError = [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorUnknown
                                        userInfo:userInfo];
    }

    if (error != NULL) {
        *error = internalError;
    }
    return internalError == nil;
}

- (void)completeDownloadSourceURL:(NSURL *)sourceURL fileURL:(NSURL *)fileURL
{
    BOOL shouldProcessGlobalCompletion = NO;
    @synchronized (self) {
        self.tasks[sourceURL] = nil;
        self.downloadedFiles[sourceURL] = fileURL;
        if (self.tasks.count == 0 && self.complete == NO) {
            shouldProcessGlobalCompletion = YES;
            self.complete = YES;
        }
    }

    if (shouldProcessGlobalCompletion) {
        [self processGlobalCompletion];
    }
}

- (void)completeDownloadSourceURL:(NSURL *)sourceURL withError:(NSError *)error
{
    BOOL shouldCallCallback = NO;
    NSArray *pendingTasks = nil;
    @synchronized (self) {
        self.tasks[sourceURL] = nil;
        if (self.complete == NO) {
            pendingTasks = self.tasks.allValues;
            [self.tasks removeAllObjects];
            shouldCallCallback = YES;
            self.complete = YES;
        }
    }
    if (shouldCallCallback) {
        for (NSURLSessionTask *task in pendingTasks) {
            [task cancel];
        }
        [self completeWithAttachments:nil error:error];
    }
}

- (void)processGlobalCompletion
{
    NSError *error = nil;
    NSMutableArray *attachments = [NSMutableArray array];
    for (AMPAttachmentPayload *payload in self.attachments) {
        NSURL *fileURL = self.downloadedFiles[payload.url];
        NSDictionary *options = nil;
        if (payload.fileUTI != nil) {
            options = @{ UNNotificationAttachmentOptionsTypeHintKey: payload.fileUTI };
        }
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:payload.identifier
                                                                                              URL:fileURL
                                                                                          options:options
                                                                                            error:&error];
        if (attachment != nil) {
            [attachments addObject:attachment];
        }
        else {
            attachments = nil;
            [self.tracker reportAttachmentDownloadError:error stage:@"attachment_creation"];
            break;
        }
    }
    [self completeWithAttachments:[attachments copy] error:error];
}

- (NSURL *)tempFileURLWithExtension:(NSString *)extension
{
    NSString *tempDirectoryPath = NSTemporaryDirectory();
    NSString *fileWithoutExtensionPath = [tempDirectoryPath stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSString *filePath = [fileWithoutExtensionPath stringByAppendingPathExtension:extension];
    return [NSURL fileURLWithPath:filePath];
}

- (void)completeWithAttachments:(NSArray *)attachments error:(NSError *)error
{
    if (self.callback != nil) {
        self.callback(attachments, error);
    }
}

@end
