
#import "AMPLazyLocationPayload.h"


@implementation AMPLazyLocationPayload

- (instancetype)initWithMinRecency:(NSNumber *)minRecency
                       minAccuracy:(NSNumber *)minAccuracy
{
    self = [super init];
    if (self != nil) {
        _minRecency = minRecency;
        _minAccuracy = minAccuracy;
    }
    return self;
}

@end
