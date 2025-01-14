
#import <UIKit/UIKit.h>

#if __has_include("AMPAppMetricaPushEnvironment.h")
    #import "AMPAppMetricaPushEnvironment.h"
    #import "AMPUserNotificationCenterDelegate.h"
    #import "AMPUserNotificationCenterHandling.h"
#else
    #import <AppMetricaPush/AMPAppMetricaPushEnvironment.h>
    #import <AppMetricaPush/AMPUserNotificationCenterDelegate.h>
    #import <AppMetricaPush/AMPUserNotificationCenterHandling.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef void (^AMPAttachmentsDownloadCallback)(NSArray<UNNotificationAttachment *> * _Nullable attachments,
                                               NSError * _Nullable error) NS_SWIFT_UNAVAILABLE("use swift closures instead");
typedef void (^AMPPushControllerCallback)(UNNotificationContent * _Nullable content,
                                          NSError * _Nullable error) NS_SWIFT_UNAVAILABLE("use swift closures instead");

extern NSString *const kAMPAppMetricaPushErrorDomain;

NS_SWIFT_NAME(AppMetricaPush)
@interface AMPAppMetricaPush : NSObject

/** Returning AMPUserNotificationCenterDelegate that handles foreground push notifications on iOS 10+.
 The AMPUserNotificationCenterDelegate protocol is derived from UNUserNotificationCenterDelegate.
 To handle foreground push notifications, execute this line before the application finishes its launching process:

 [UNUserNotificationCenter currentNotificationCenter].delegate = [AMPPushMetricaPush userNotificationCenterDelegate];

 If you want to handle push notifications on your own, use +userNotificationCenterHandler.
 */
@property (readonly, class) id<AMPUserNotificationCenterDelegate> userNotificationCenterDelegate;

/** Returning AMPUserNotificationCenterDelegate that allows handling foreground push notifications on iOS 10+.
 Use this delegate if you implement UNUserNotificationCenterDelegate protocol with custom logic.
 You should implement every method from UNUserNotificationCenterDelegate and call proper methods of this delegate.

 If you want a simplier way to handle push notification use +userNotificationCenterDelegate.
 */
@property (readonly, class) id<AMPUserNotificationCenterHandling> userNotificationCenterHandler;

/** Handling a push notification from the notification service extension.
 Should be called in the didReceiveNotificationRequest:withContentHandler: method implementation.

 @param request The current request.
 */
+ (void)handleDidReceiveNotificationRequest:(UNNotificationRequest *)request;

/** Downloading push notification attachments content.
 If any error occurs during downloading it is provided in the callback.
 Otherwise, array of UNNotificationAttachment objects is provided.
 The callback block will be called on the network queue of the shared NSURLSession.

 @param request The current request.
 @param callback The callback of downloading completion.
 */
+ (void)downloadAttachmentsForNotificationRequest:(UNNotificationRequest *)request
                                         callback:(nullable AMPAttachmentsDownloadCallback)callback;

/** Processing notification content. Calls resultHandler with processed UNNotificationContent and error description.

 @param request The current request
 @param resultHandler The callback for processing completion
 */
+ (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                    withResultHandler:(nullable AMPPushControllerCallback)resultHandler;

/** Setting push notification device token with production environment.
 If value is nil, previously set device token is revoked.
 Should be called after AppMetrica initialization.

 @param data Device token data.
 */
+ (void)setDeviceTokenFromData:(nullable NSData *)data;

/** Setting push notification device token with specific environment.
 If value is nil, previously set device token is revoked.
 Should be called after AppMetrica initialization.

 @param data Device token data.
 @param pushEnvironment Application APNs environment.
 */
+ (void)setDeviceTokenFromData:(nullable NSData *)data pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment;

/** Handling push notification from application launch options.
 Should be called after AppMetrica initialization.

 @param launchOptions A dictionary that contains information related to the
 application launch options, potentially including a notification info.
 */
+ (void)handleApplicationDidFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;

/** Handling push notification from scene connection options.
 Should be called in `scene:willConnectToSession:options:` of `UISceneDelegate`
 after AppMetrica initialization.

 @param connectionOptions `UIScene` connection options.
 An object containing scene connection information,
 potentially including a notification info.
 */
+ (void)handleSceneWillConnectToSessionWithOptions:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0));

/** Handling push notification event.
 Should be called after AppMetrica initialization.

 @param userInfo A dictionary that contains information related to the remote notification,
 potentially including a badge number for the app icon, an alert sound,
 an alert message to display to the user, a notification identifier
 and custom data.
 */
+ (void)handleRemoteNotification:(NSDictionary *)userInfo;

/** Returning user data string from push notification payload.

 @param userInfo A dictionary that contains information related to the remote notification,
 potentially including a badge number for the app icon, an alert sound,
 an alert message to display to the user, a notification identifier
 and custom data.
 @return A string with custom user data.
 */
+ (nullable NSString *)userDataForNotification:(NSDictionary *)userInfo;

/** Returning YES if push notification is related to AppMetrica.

 @param userInfo A dictionary that contains information related to the remote notification,
 potentially including a badge number for the app icon, an alert sound,
 an alert message to display to the user, a notification identifier
 and custom data.
 @return YES for SDK related notifications.
 */
+ (BOOL)isNotificationRelatedToSDK:(NSDictionary *)userInfo;

/** Informing the library about appGroup that is shared between the app and notification service extension.
 Since 3.0.0 AppMetricaPush sends events in extension. Use this method if you need to send saved notifications in application.

 This method will be removed in future.

 @param appGroup Shared appGroup between the app and notification service extension.
 */
+ (void)setExtensionAppGroup:(NSString *)appGroup;

@end

NS_ASSUME_NONNULL_END
