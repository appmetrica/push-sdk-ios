
#import "AMPAppMetricaPushTracker.h"

#import "AMPEventsController.h"
#import "AMPPushNotificationController.h"

@implementation AMPAppMetricaPushTracker

+ (void)reportReceive:(NSString *)notificationID onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPEventsController sharedInstance] reportPushNotificationWithNotificationID:notificationID
                                                                        actionType:kAMPEventsControllerActionTypeReceive
                                                                          actionID:nil
                                                                         onFailure:onFailure];
}

+ (void)reportReceiveInExtension:(NSString *)notificationID
                       onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPPushNotificationController sharedInstance] handleDidReceiveNotificationWithNotificationID:notificationID];
}

+ (void)reportOpen:(NSString *)notificationID onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPEventsController sharedInstance] reportPushNotificationWithNotificationID:notificationID
                                                                        actionType:kAMPEventsControllerActionTypeOpen
                                                                          actionID:nil
                                                                         onFailure:onFailure];
}

+ (void)reportProcess:(NSString *)notificationID onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPEventsController sharedInstance] reportPushNotificationWithNotificationID:notificationID
                                                                        actionType:kAMPEventsControllerActionTypeProcessed
                                                                          actionID:nil
                                                                         onFailure:onFailure];
}

+ (void)reportDismiss:(NSString *)notificationID onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPEventsController sharedInstance] reportPushNotificationWithNotificationID:notificationID
                                                                        actionType:kAMPEventsControllerActionTypeDismiss
                                                                          actionID:nil
                                                                         onFailure:onFailure];
}

+ (void)reportAdditionalAction:(NSString *)actionID
                notificationID:(NSString *)notificationID
                     onFailure:(AMPAppMetricaPushTrackerReportFailure)onFailure
{
    [[AMPEventsController sharedInstance] reportPushNotificationWithNotificationID:notificationID
                                                                        actionType:kAMPEventsControllerActionTypeCustom
                                                                          actionID:actionID
                                                                         onFailure:onFailure];
}

@end
