
#import <Kiwi/Kiwi.h>

#import "AMPEnvironmentProvider.h"
#import "AMPVersion.h"

SPEC_BEGIN(AMPEnvironmentProviderTests)

describe(@"AMPEnvironmentProvider", ^{

    let(environmentProvider, ^id{
        return [[AMPEnvironmentProvider alloc] init];
    });

    it(@"Should return common environment with sdk version", ^{
        NSDictionary *environment = [environmentProvider commonEnvironment];
        NSUInteger version = (((AMP_VERSION_MAJOR) * 10 + AMP_VERSION_MINOR) * 10 + AMP_VERSION_PATCH);
        [[environment[@"appmetrica_push_version"] should] equal:@(version)];
    });

    it(@"Should return common environment with sdk version name", ^{
        NSDictionary *environment = [environmentProvider commonEnvironment];
        NSString *versionString =
            [NSString stringWithFormat:@"%@.%@.%@", @AMP_VERSION_MAJOR, @AMP_VERSION_MINOR, @AMP_VERSION_PATCH];
        [[environment[@"appmetrica_push_version_name"] should] equal:versionString];
    });

    it(@"Should return common environment for notification environment", ^{
        NSDictionary *commonEnvironment = [environmentProvider commonEnvironment];
        NSDictionary *notificationEnvironment = [environmentProvider notificationEventEnvironment];
        [[notificationEnvironment should] equal:commonEnvironment];
    });

    it(@"Should contain common environment in token environment", ^{
        NSDictionary *commonEnvironment = [environmentProvider commonEnvironment];
        NSDictionary *tokenEnvironment =
            [environmentProvider tokenEventEnvironmentForPushEnvironment:AMPAppMetricaPushEnvironmentProduction];
        NSDictionary *interception = [tokenEnvironment dictionaryWithValuesForKeys:commonEnvironment.allKeys];
        [[interception should] equal:commonEnvironment];
    });

    it(@"Should contain production push environment in token environment", ^{
        NSDictionary *tokenEnvironment =
            [environmentProvider tokenEventEnvironmentForPushEnvironment:AMPAppMetricaPushEnvironmentProduction];
        [[tokenEnvironment[@"ios_aps_environment"] should] equal:@"production"];
    });

    it(@"Should contain development push environment in token environment", ^{
        NSDictionary *tokenEnvironment =
            [environmentProvider tokenEventEnvironmentForPushEnvironment:AMPAppMetricaPushEnvironmentDevelopment];
        [[tokenEnvironment[@"ios_aps_environment"] should] equal:@"development"];
    });

});

SPEC_END
