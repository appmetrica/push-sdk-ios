
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AMPAppMetricaPushTrackerReportFailure)(NSError *error);

/** Use this class for manual tracking of your own push notifications.
 See internal documentation for more information about identifiers and integration.
 */
NS_SWIFT_NAME(AppMetricaPushTracker)
@interface AMPAppMetricaPushTracker : NSObject

/** Reporting push notification receive event.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportReceive:(NSString *)notificationID onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting push notification receive event handled in Notification Service Extension.
 Should be called after AppGroup is set with + [AMAPushMetricaPush setExtensionAppGroup:] method.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportReceiveInExtension:(NSString *)notificationID
                       onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting push notification open by user event.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportOpen:(NSString *)notificationID onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting push notification open by user event.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param uri uri that received in payload
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportOpen:(NSString *)notificationID
               uri:(nullable NSString *)uri
         onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting processing silent push notification.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportProcess:(NSString *)notificationID onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting push notification dismissed by user event.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportDismiss:(NSString *)notificationID onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

/** Reporting push notification action reacted by user event.
 Should be called after AppMetrica initialization.
 See internal documentation for more information about identifiers and integration.

 @param actionID Action identifier.
 @param notificationID Notification identifier.
 @param onFailure Block to be executed if an error occurres while reporting, the error is passed as block argument.
 */
+ (void)reportAdditionalAction:(NSString *)actionID
                notificationID:(NSString *)notificationID
                     onFailure:(nullable AMPAppMetricaPushTrackerReportFailure)onFailure;

@end

NS_ASSUME_NONNULL_END
