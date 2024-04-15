
#import <Foundation/Foundation.h>

@class AMPPushNotificationPayload;

@interface AMPTrackingDeduplicationController : NSObject

- (BOOL)shouldReportEventForNotification:(AMPPushNotificationPayload *)notification;
- (void)markEventReportedForNotification:(AMPPushNotificationPayload *)notification;

@end
