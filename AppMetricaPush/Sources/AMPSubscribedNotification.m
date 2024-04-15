
#import "AMPSubscribedNotification.h"

@implementation AMPSubscribedNotification

- (instancetype)initWithName:(NSString *)name enabled:(BOOL)enabled
{
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _enabled = enabled;
    }
    return self;
}

- (BOOL)isEqual:(AMPSubscribedNotification *)object
{
    return [self.name isEqualToString:object.name] && self.enabled == object.enabled;
}

- (nonnull id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
