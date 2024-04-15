
@class UNNotification;
@class UNNotificationResponse;

NS_ASSUME_NONNULL_BEGIN

/** A delegate for manual handling foreground push notifications on iOS 10+.
 Use this delegate if you implement the UNUserNotificationCenterDelegate protocol with custom logic.
 You should implement all methods of UNUserNotificationCenterDelegate and call proper methods of this delegate.

 Implementation of this delegate is provided by [AMPAppMetricaPush userNotificationCenterHandler].
 */
NS_SWIFT_NAME(UserNotificationCenterHandling)
@protocol AMPUserNotificationCenterHandling <NSObject>

/** Call this method in your implementation of userNotificationCenter:willPresentNotification:withCompletionHandler:.
 */
- (void)userNotificationCenterWillPresentNotification:(UNNotification *)notification;

/** Call this method in your implementation of userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:.
 */
- (void)userNotificationCenterDidReceiveNotificationResponse:(UNNotificationResponse *)response;

/** Call this method in your implementation of userNotificationCenter:openSettingsForNotification:.
 */
- (void)userNotificationCenterOpenSettingsForNotification:(nullable UNNotification *)notification;

@end

NS_ASSUME_NONNULL_END
