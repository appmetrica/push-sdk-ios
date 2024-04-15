
#import "AMPPendingPush.h"

@implementation AMPPendingPush

- (instancetype)initWithNotificationID:(NSString *)notificationID receivingDate:(NSDate *)receivingDate
{
    self = [super init];
    if (self != nil) {
        _notificationID = [notificationID copy];
        _receivingDate = [receivingDate copy];
    }
    return self;
}

@end
