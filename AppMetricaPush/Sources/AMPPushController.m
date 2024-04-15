
#import <UserNotifications/UserNotifications.h>
#import "AMPPushController.h"
#import "AMPPushAttachmentProcessor.h"
#import "AMPPushNotificationProcessor.h"
#import "AMPLazyPushProvider.h"

@implementation AMPPushController

+ (instancetype)sharedInstance
{
    static AMPPushController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[AMPPushController alloc] init];
    });
    return controller;
}

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(nullable AMPPushProcessorCallback)resultHandler
{
    AMPPushProcessorCallback attachmentCallback = ^(UNNotificationContent *content, NSError *error) {
        if (error == nil) {
            [[AMPPushAttachmentProcessor sharedInstance] processNotificationContent:content
                                                                  withResultHandler:resultHandler];
        }
        else if (resultHandler != nil) {
            resultHandler(nil, error);
        }
    };
    AMPPushProcessorCallback lazyPushCallback = ^(UNNotificationContent *content, NSError *error) {
        if (error == nil) {
            [[AMPLazyPushProvider sharedInstance] processNotificationContent:content
                                                           withResultHandler:attachmentCallback];
        }
        else if (resultHandler != nil) {
            resultHandler(nil, error);
        }
    };
    AMPPushProcessorCallback notificationCallback = ^(UNNotificationContent *content, NSError *error) {
        if (error == nil) {
            [[AMPPushNotificationProcessor sharedInstance] processNotificationContent:content
                                                                    withResultHandler:lazyPushCallback];
        }
        else if (resultHandler != nil) {
            resultHandler(nil, error);
        }
    };
    notificationCallback(content, nil);
}

@end
