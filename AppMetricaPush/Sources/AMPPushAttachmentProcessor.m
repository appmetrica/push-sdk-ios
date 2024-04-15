
#import "AMPPushAttachmentProcessor.h"
#import "AMPAttachmentsController.h"

#import <UserNotifications/UserNotifications.h>

@implementation AMPPushAttachmentProcessor

+ (instancetype)sharedInstance
{
    static AMPPushAttachmentProcessor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AMPPushAttachmentProcessor alloc] init];
    });
    return instance;
}

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(AMPPushProcessorCallback)resultHandler
{
    [[AMPAttachmentsController sharedInstance] downloadAttachmentsForUserInfo:content.userInfo
                                                                     callback:^(NSArray *attachments, NSError *error) {
        if (resultHandler != nil) {
            if (error != nil) {
                resultHandler(nil, error);
            }
            else {
                UNMutableNotificationContent *mutableContent = (UNMutableNotificationContent *) [content mutableCopy];
                mutableContent.attachments = attachments;
                resultHandler(mutableContent, nil);
            };
        }
    }];
}

@end
