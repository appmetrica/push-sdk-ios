
#import "AMPUserNotificationCenterHandler.h"
#import "AMPPushNotificationController.h"

#import <UserNotifications/UserNotifications.h>

@interface AMPUserNotificationCenterHandler ()

@property (nonatomic, strong, readonly) AMPPushNotificationController *controller;

@end

@implementation AMPUserNotificationCenterHandler

- (instancetype)init
{
    return [self initWithPushNotificationController:[AMPPushNotificationController sharedInstance]];
}

- (instancetype)initWithPushNotificationController:(AMPPushNotificationController *)controller
{
    self = [super init];
    if (self != nil) {
        _controller = controller;
    }
    return self;
}

- (void)userNotificationCenterWillPresentNotification:(UNNotification *)notification
{
    // Do nothing here
}

- (void)userNotificationCenterOpenSettingsForNotification:(UNNotification *)notification
{
    // Do nothing here
}

- (void)userNotificationCenterDidReceiveNotificationResponse:(UNNotificationResponse *)response
{
    [self handleNotificationResponse:response];
}

- (void)handleNotificationResponse:(UNNotificationResponse *)response
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;

    if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        [self.controller handlePushNotificationDismissWithUserInfo:userInfo];
        return;
    }

    [self.controller handleUserNotificationCenterPush:userInfo];
}

+ (instancetype)sharedInstance
{
    static AMPUserNotificationCenterHandler *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[AMPUserNotificationCenterHandler alloc] init];
    });
    return delegate;
}

@end
