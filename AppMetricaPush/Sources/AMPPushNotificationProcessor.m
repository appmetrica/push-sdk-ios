
#import "AMPPushNotificationProcessor.h"
#import "AMPPushNotificationController.h"

#import <UserNotifications/UserNotifications.h>


@implementation AMPPushNotificationProcessor

+ (instancetype)sharedInstance {
    static AMPPushNotificationProcessor *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[AMPPushNotificationProcessor alloc] init];
    });
    return controller;
}

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(AMPPushProcessorCallback)resultHandler
{
    NSDictionary *userInfo = content.userInfo;
    [[AMPPushNotificationController sharedInstance] handleDidReceiveNotificationRequestWithUserInfo:userInfo];
    if (resultHandler != nil) {
        resultHandler(content, nil);
    }
}

@end
