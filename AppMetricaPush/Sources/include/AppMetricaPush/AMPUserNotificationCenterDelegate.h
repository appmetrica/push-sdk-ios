
#import <UserNotifications/UserNotifications.h>

/** A delegate for handling foreground push notifications on iOS 10+.
 To handle foreground push notifications, execute this line before the application finishes its launching process:

 [UNUserNotificationCenter currentNotificationCenter].delegate = [AMPAppMetricaPush userNotificationCenterDelegate];
 */
NS_SWIFT_NAME(UserNotificationCenterDelegate)
@protocol AMPUserNotificationCenterDelegate <UNUserNotificationCenterDelegate>

@required

/** Notification presentation options to be passed into completion handler of
 userNotificationCenter:willPresentNotification:withCompletionHandler:

 This delegate calls handler only if nextDelegate property is not set
 or if an object in nextDelegate doesn't respond to the selector above.
 */
@property (nonatomic, assign) UNNotificationPresentationOptions presentationOptions;

/** Delegate to which calls of this protocol will be proxied.
 */
@property (nonatomic, weak, nullable) id<UNUserNotificationCenterDelegate> nextDelegate;

@end

