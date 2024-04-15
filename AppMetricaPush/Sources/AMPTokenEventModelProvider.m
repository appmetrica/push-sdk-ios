
#import "AMPTokenEventModelProvider.h"
#import "AMPSubscribedNotification.h"
#import "AMPTokenEvent.h"
#import "AMPApplication.h"

@implementation AMPTokenEventModelProvider

+ (void)addNotificationTo:(NSMutableArray *)notifications
                 withName:(NSString *)name
                     type:(UIUserNotificationType)type
                 forTypes:(UIUserNotificationType)notificationTypes
{
    [notifications addObject:[[AMPSubscribedNotification alloc] initWithName:name
                                                                     enabled:(notificationTypes & type)]];
}

+ (void)retrieveTokenEventWithToken:(NSString *)token block:(void(^)(AMPTokenEvent *tokenModel))block
{
    [AMPApplication retrieveNotificationSettingsTypesWithBlock:^(UIUserNotificationType notificationTypes) {
        NSMutableArray *subscribedNotifications = [NSMutableArray array];
        [self addNotificationTo:subscribedNotifications
                       withName:@"badge"
                           type:UIUserNotificationTypeBadge
                       forTypes:notificationTypes];
        [self addNotificationTo:subscribedNotifications
                       withName:@"sound"
                           type:UIUserNotificationTypeSound
                       forTypes:notificationTypes];
        [self addNotificationTo:subscribedNotifications
                       withName:@"alert"
                           type:UIUserNotificationTypeAlert
                       forTypes:notificationTypes];
        BOOL hasEnabled = false;
        for (AMPSubscribedNotification *notification in subscribedNotifications) {
            hasEnabled = hasEnabled || notification.enabled;
        }
        AMPTokenEvent *tokenModel = [[AMPTokenEvent alloc] initWithToken:(NSString *)token
                                                                 enabled:(BOOL)hasEnabled
                                                           notifications:(NSArray *)subscribedNotifications];
        if (block != nil) {
            block(tokenModel);
        }
    }];
}

@end
