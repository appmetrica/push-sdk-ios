
#import <Foundation/Foundation.h>

@class AMPAttachmentPayload;
@class AMPLibraryAnalyticsTracker;
@class UNNotificationAttachment;

typedef void (^AMPAttachmentsLoaderCallback)(NSArray<UNNotificationAttachment *> *attachments, NSError *error);

@interface AMPAttachmentsLoader : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAttachments:(NSArray<AMPAttachmentPayload *> *)attachments;
- (instancetype)initWithAttachments:(NSArray<AMPAttachmentPayload *> *)attachments
                         urlSession:(NSURLSession *)urlSession
                        fileManager:(NSFileManager *)fileManager
                            tracker:(AMPLibraryAnalyticsTracker *)tracker;

- (void)downloadWithCallback:(AMPAttachmentsLoaderCallback)callback;

@end
