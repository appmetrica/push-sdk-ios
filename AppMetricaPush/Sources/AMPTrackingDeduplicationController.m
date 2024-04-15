
#import "AMPTrackingDeduplicationController.h"
#import "AMPPushNotificationPayload.h"

@interface AMPTrackingDeduplicationController ()

@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *trackedEventKeys;

@end

@implementation AMPTrackingDeduplicationController

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _trackedEventKeys = [NSMutableSet set];
    }
    return self;
}

- (BOOL)shouldReportEventForNotification:(AMPPushNotificationPayload *)notification
{
    if (notification == nil) {
        return NO;
    }
    NSString *key = [self keyForNotification:notification];
    return key == nil || [self.trackedEventKeys containsObject:key] == NO;
}

- (void)markEventReportedForNotification:(AMPPushNotificationPayload *)notification
{
    NSString *key = [self keyForNotification:notification];
    if (key != nil) {
        [self.trackedEventKeys addObject:key];
    }
}

- (NSString *)keyForNotification:(AMPPushNotificationPayload *)notification
{
    return notification.notificationID;
}

@end
