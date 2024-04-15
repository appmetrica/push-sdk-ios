
#import "AMPPendingPushSerializer.h"
#import "AMPPendingPush.h"

static NSString *const kAMPNotificationIDKey = @"notificationID";
static NSString *const kAMPReceivingDateKey = @"receivingDate";

@implementation AMPPendingPushSerializer

+ (AMPPendingPush *)pushForDictionaty:(NSDictionary *)serializedPush
{
    NSString *notificationID = serializedPush[kAMPNotificationIDKey];
    NSDate *receivingDate = serializedPush[kAMPReceivingDateKey];
    return [[AMPPendingPush alloc] initWithNotificationID:notificationID receivingDate:receivingDate];
}

+ (NSDictionary *)dictionaryForPush:(AMPPendingPush *)push
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kAMPNotificationIDKey] = push.notificationID;
    dict[kAMPReceivingDateKey] = push.receivingDate;
    return dict;
}

@end
