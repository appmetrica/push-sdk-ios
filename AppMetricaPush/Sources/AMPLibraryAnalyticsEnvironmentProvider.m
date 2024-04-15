
#import "AMPLibraryAnalyticsEnvironmentProvider.h"

@implementation AMPLibraryAnalyticsEnvironmentProvider

- (NSDictionary *)commonEnvironment
{
    NSMutableDictionary *extendedEnvironment = [[super commonEnvironment] mutableCopy] ?: [NSMutableDictionary dictionary];
    [extendedEnvironment addEntriesFromDictionary:@{
        @"app_id": ([[NSBundle mainBundle] bundleIdentifier] ?: @"unknown")
    }];
    return [extendedEnvironment copy];
}

@end
