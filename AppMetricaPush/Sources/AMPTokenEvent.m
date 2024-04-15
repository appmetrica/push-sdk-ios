
#import "AMPTokenEvent.h"

@implementation AMPTokenEvent

- (instancetype)initWithToken:(NSString *)token enabled:(BOOL)enabled notifications:(NSArray *)notifications
{
    self = [super init];
    if (self != nil) {
        _token = [token copy];
        _enabled = enabled;
        _notifications = [notifications copy];
    }
    return self;
}

@end
