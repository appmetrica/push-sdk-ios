
#import <Kiwi/Kiwi.h>
#import "AMPAttachmentsLoader.h"
#import "AMPAttachmentPayload.h"
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPTestUtilities.h"
#import <UserNotifications/UserNotifications.h>

SPEC_BEGIN(AMPAttachmentsLoaderTests)

describe(@"AMPAttachmentsLoader", ^{

    NSString *firstAttachmentID = @"FIRST_ID";
    NSURL *firstAttachmentURL = [NSURL URLWithString:@"https://first.attachment.url"];
    NSString *firstAttachmentUTI = @"FIRST_UTI";
    NSString *secondAttachmentID = @"SECOND_ID";
    NSURL *secondAttachmentURL = [NSURL URLWithString:@"https://second.attachment.url"];
    NSString *secondAttachmentUTI = @"SECOND_UTI";
    NSArray *const attachments = @[
        [[AMPAttachmentPayload alloc] initWithIdentifier:firstAttachmentID
                                                     url:firstAttachmentURL
                                                 fileUTI:firstAttachmentUTI],
        [[AMPAttachmentPayload alloc] initWithIdentifier:secondAttachmentID
                                                     url:secondAttachmentURL
                                                 fileUTI:secondAttachmentUTI],
    ];
    NSURL *const firstFileURL = [NSURL URLWithString:@"file//path/to/first/file"];
    NSURL *const secondFileURL = [NSURL URLWithString:@"file//path/to/second/file"];

    NSMutableDictionary *__block tasks = nil;
    NSMutableDictionary *__block movePlaces = nil;
    NSURLSession *__block urlSession = nil;
    NSFileManager *__block fileManager = nil;
    AMPLibraryAnalyticsTracker *__block tracker = nil;
    AMPAttachmentsLoader *__block loader = nil;

    NSArray *__block attachmentsFromCallback = nil;
    NSError *__block errorsFromCallback = nil;
    BOOL __block callbackCalled = NO;
    NSError *__block trackedError = nil;
    NSString *__block trackedStage = nil;
    BOOL __block trackingCalled = NO;

    void (^stubFileManager)(void) = ^{
        [fileManager stub:@selector(moveItemAtURL:toURL:error:) withBlock:^id(NSArray *params) {
            movePlaces[params[0]] = params[1];
            return theValue(YES);
        }];
    };

    id (^attachmentConstructorStub)(NSArray *) = ^id(NSArray *params) {
        UNNotificationAttachment *attachment = [UNNotificationAttachment nullMock];
        [attachment stub:@selector(identifier) andReturn:params[0]];
        [attachment stub:@selector(URL) andReturn:params[1]];
        [attachment stub:@selector(type) andReturn:params[2][UNNotificationAttachmentOptionsTypeHintKey]];
        return attachment;
    };

    beforeEach(^{
        attachmentsFromCallback = nil;
        errorsFromCallback = nil;
        callbackCalled = NO;
        trackedError = nil;
        trackedStage = nil;
        trackingCalled = NO;

        tasks = [NSMutableDictionary dictionary];
        movePlaces = [NSMutableDictionary dictionary];
        urlSession = [NSURLSession nullMock];
        [urlSession stub:@selector(downloadTaskWithURL:completionHandler:) withBlock:^id(NSArray *params) {
            NSURL *url = params[0];
            tasks[url] = params[1];
            return [NSURLSessionDataTask nullMock];
        }];
        fileManager = [NSFileManager nullMock];
        stubFileManager();
        [UNNotificationAttachment stub:@selector(attachmentWithIdentifier:URL:options:error:)
                             withBlock:attachmentConstructorStub];
        tracker = [AMPLibraryAnalyticsTracker mock];
        [tracker stub:@selector(reportAttachmentDownloadError:stage:) withBlock:^id(NSArray *params) {
            trackedError = params[0];
            trackedStage = params[1];
            trackingCalled = YES;
            return nil;
        }];
        loader = [[AMPAttachmentsLoader alloc] initWithAttachments:attachments
                                                        urlSession:urlSession
                                                       fileManager:fileManager
                                                           tracker:tracker];
    });

    void (^completeTask)(NSURL *, NSURL *, NSURLResponse *, NSError *) =
        ^(NSURL *sourceURL, NSURL *fileURL, NSURLResponse *response, NSError *error) {
            void (^callback)(NSURL *, NSURLResponse *, NSError *) = tasks[sourceURL];
            if (callback != nil) {
                callback(fileURL, response, error);
                tasks[sourceURL] = nil;
            }
        };

    AMPAttachmentsLoaderCallback defaultCallback = ^(NSArray *attachments, NSError *error) {
        attachmentsFromCallback = attachments;
        errorsFromCallback = error;
        callbackCalled = YES;
    };

    context(@"Empty attachments array", ^{
        beforeEach(^{
            loader = [[AMPAttachmentsLoader alloc] initWithAttachments:@[]];
            [loader downloadWithCallback:defaultCallback];
        });
        it(@"Should call callback", ^{
            [[theValue(callbackCalled) should] beYes];
        });
        it(@"Should return nil error", ^{
            [[errorsFromCallback should] beNil];
        });
        it(@"Should return empty attachments array", ^{
            [[attachmentsFromCallback should] beEmpty];
        });
        it(@"Should not track error", ^{
            [[theValue(trackingCalled) should] beNo];
        });
    });

    it(@"Should start tasks for both attachments", ^{
        [loader downloadWithCallback:nil];
        [[[NSSet setWithArray:tasks.allKeys] should] equal:[NSSet setWithArray:@[firstAttachmentURL, secondAttachmentURL]]];
    });

    it(@"Should not complete if loaded only one", ^{
        [loader downloadWithCallback:defaultCallback];
        completeTask(firstAttachmentURL, firstFileURL, nil, nil);
        [[theValue(callbackCalled) should] beNo];
    });

    context(@"One failed to load", ^{
        NSError *const loadError = [NSError errorWithDomain:@"foo" code:3 userInfo:@{ @"foo": @"bar" }];
        beforeEach(^{
            [loader downloadWithCallback:defaultCallback];
            completeTask(firstAttachmentURL, nil, nil, loadError);
        });
        it(@"Should return error", ^{
            [[errorsFromCallback should] equal:loadError];
        });
        it(@"Should return nil atatchments", ^{
            [[attachmentsFromCallback should] beNil];
        });
        it(@"Should not call callback after second file is loaded", ^{
            callbackCalled = NO;
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
            [[theValue(callbackCalled) should] beNo];
        });
        it(@"Should track error", ^{
            [[trackedError should] equal:loadError];
        });
        it(@"Should track stage", ^{
            [[trackedStage should] equal:@"network"];
        });
    });

    context(@"One has non-200 status code", ^{
        NSUInteger const statusCode = 404;
        NSDictionary *const expectedUserInfo = @{
            NSLocalizedDescriptionKey: @"HTTP response status is not 200.",
            @"NSHTTPURLResponseStatusCode": @(statusCode)
        };
        NSError *const expectedError = [NSError errorWithDomain:NSURLErrorDomain
                                                           code:NSURLErrorUnknown
                                                       userInfo:expectedUserInfo];

        beforeEach(^{
            NSHTTPURLResponse *response = [NSHTTPURLResponse nullMock];
            [response stub:@selector(statusCode) andReturn:theValue(statusCode)];
            [loader downloadWithCallback:defaultCallback];
            completeTask(firstAttachmentURL, nil, response, nil);
        });
        it(@"Should return error", ^{
            [[errorsFromCallback should] equal:expectedError];
        });
        it(@"Should return nil atatchments", ^{
            [[attachmentsFromCallback should] beNil];
        });
        it(@"Should not call callback after second file is loaded", ^{
            callbackCalled = NO;
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
            [[theValue(callbackCalled) should] beNo];
        });
        it(@"Should track error", ^{
            [[trackedError should] equal:expectedError];
        });
        it(@"Should track stage", ^{
            [[trackedStage should] equal:@"http_status"];
        });
    });

    context(@"One failed to move", ^{
        NSError *const moveError = [NSError errorWithDomain:@"foo" code:4 userInfo:@{ @"foo": @"bar" }];
        beforeEach(^{
            [loader downloadWithCallback:defaultCallback];
            [fileManager stub:@selector(moveItemAtURL:toURL:error:) withBlock:^id(NSArray *params) {
                [AMPTestUtilities fillObjectPointerParameter:params[2] withValue:moveError];
                return theValue(NO);
            }];
            completeTask(firstAttachmentURL, firstFileURL, nil, nil);
            stubFileManager();
        });
        it(@"Should return error", ^{
            [[errorsFromCallback should] equal:moveError];
        });
        it(@"Should return nil atatchments", ^{
            [[attachmentsFromCallback should] beNil];
        });
        it(@"Should not call callback after second file is loaded", ^{
            callbackCalled = NO;
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
            [[theValue(callbackCalled) should] beNo];
        });
        it(@"Should track error", ^{
            [[trackedError should] equal:moveError];
        });
        it(@"Should track stage", ^{
            [[trackedStage should] equal:@"file_move"];
        });
    });

    context(@"One failed to create attachment", ^{
        NSError *const createError = [NSError errorWithDomain:@"foo" code:5 userInfo:@{ @"foo": @"bar" }];
        beforeEach(^{
            [loader downloadWithCallback:defaultCallback];
            [UNNotificationAttachment stub:@selector(attachmentWithIdentifier:URL:options:error:) withBlock:^id(NSArray *params) {
                if ([params[0] isEqual:firstAttachmentID]) {
                    [AMPTestUtilities fillObjectPointerParameter:params[3] withValue:createError];
                    return nil;
                }
                return attachmentConstructorStub(params);
            }];
            completeTask(firstAttachmentURL, firstFileURL, nil, nil);
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
        });
        it(@"Should return error", ^{
            [[errorsFromCallback should] equal:createError];
        });
        it(@"Should return nil atatchments", ^{
            [[attachmentsFromCallback should] beNil];
        });
        it(@"Should not call callback after second file is loaded", ^{
            callbackCalled = NO;
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
            [[theValue(callbackCalled) should] beNo];
        });
        it(@"Should track error", ^{
            [[trackedError should] equal:createError];
        });
        it(@"Should track stage", ^{
            [[trackedStage should] equal:@"attachment_creation"];
        });
    });

    context(@"Complete both files load", ^{
        beforeEach(^{
            [loader downloadWithCallback:defaultCallback];
            completeTask(firstAttachmentURL, firstFileURL, nil, nil);
            completeTask(secondAttachmentURL, secondFileURL, nil, nil);
        });
        it(@"Should call callback", ^{
            [[theValue(callbackCalled) should] beYes];
        });
        it(@"Should return nil error", ^{
            [[errorsFromCallback should] beNil];
        });
        it(@"Should return 2 attachments", ^{
            [[attachmentsFromCallback should] haveCountOf:2];
        });
        it(@"Should not call tracking", ^{
            [[theValue(trackingCalled) should] beNo];
        });
        context(@"First attachment", ^{
            UNNotificationAttachment *__block attachment = nil;
            beforeEach(^{
                for (UNNotificationAttachment *at in attachmentsFromCallback) {
                    if (at.identifier == firstAttachmentID) {
                        attachment = at;
                    }
                }
            });
            it(@"Should contain", ^{
                [[attachment shouldNot] beNil];
            });
            it(@"Should have valid URL", ^{
                [[attachment.URL should] equal:movePlaces[firstFileURL]];
            });
            it(@"Should have valid type", ^{
                [[attachment.type should] equal:firstAttachmentUTI];
            });
        });
        context(@"Second attachment", ^{
            UNNotificationAttachment *__block attachment = nil;
            beforeEach(^{
                for (UNNotificationAttachment *at in attachmentsFromCallback) {
                    if (at.identifier == secondAttachmentID) {
                        attachment = at;
                    }
                }
            });
            it(@"Should contain", ^{
                [[attachment shouldNot] beNil];
            });
            it(@"Should have valid URL", ^{
                [[attachment.URL should] equal:movePlaces[secondFileURL]];
            });
            it(@"Should have valid type", ^{
                [[attachment.type should] equal:secondAttachmentUTI];
            });
        });
    });

});

SPEC_END

