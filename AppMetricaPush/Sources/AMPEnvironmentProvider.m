
#import "AMPEnvironmentProvider.h"
#import "AMPVersion.h"

@implementation AMPEnvironmentProvider

- (NSUInteger)versionNumber
{
    return ((AMP_VERSION_MAJOR) * 10 + AMP_VERSION_MINOR) * 10 + AMP_VERSION_PATCH;
}

- (NSString *)versionName
{
#ifdef AMP_VERSION_PRERELEASE_ID
    return [NSString stringWithFormat:@"%d.%d.%d-%s",
            (int)AMP_VERSION_MAJOR, (int)AMP_VERSION_MINOR, (int)AMP_VERSION_PATCH, AMP_VERSION_PRERELEASE_ID];
#else
    return [NSString stringWithFormat:@"%d.%d.%d",
            (int)AMP_VERSION_MAJOR, (int)AMP_VERSION_MINOR, (int)AMP_VERSION_PATCH];
#endif
}

- (NSString *)pushEnvironmentStringForEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment
{
    switch (pushEnvironment) {
        case AMPAppMetricaPushEnvironmentDevelopment:
            return @"development";
        case AMPAppMetricaPushEnvironmentProduction:
            return @"production";
    }
}

- (NSDictionary *)commonEnvironment
{
    return @{
        @"appmetrica_push_version" : @([self versionNumber]),
        @"appmetrica_push_version_name": [self versionName],
    };
}

- (NSDictionary *)notificationEventEnvironment
{
    return [self commonEnvironment];
}

- (NSDictionary *)tokenEventEnvironmentForPushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment;
{
    NSMutableDictionary *environment = [[self commonEnvironment] mutableCopy];
    environment[@"ios_aps_environment"] = [self pushEnvironmentStringForEnvironment:pushEnvironment];
    return [environment copy];
}

@end
