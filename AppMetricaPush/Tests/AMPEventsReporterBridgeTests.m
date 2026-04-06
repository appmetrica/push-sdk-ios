
#import <Kiwi/Kiwi.h>

#import "AMPEventsReporterBridge.h"
#import "AMPAnalyticsProxy.h"

#import <AppMetricaCore/AppMetricaCore.h>

@interface AMPEventsReporterBridge (Tests)

@property (nonatomic, strong, nonnull) AMPAnalyticsProxy *analyticsProxy;

@end

SPEC_BEGIN(AMPEventsReporterBridgeTests)

describe(@"AMPEventsReporterBridge", ^{

    AMPAnalyticsProxy *__block analyticsProxy = nil;
    AMPEventsReporterBridge *__block bridge = nil;

    beforeEach(^{
        analyticsProxy = [AMPAnalyticsProxy nullMock];
    });
    afterEach(^{
        [AMPAnalyticsProxy clearStubs];
        [AMAAppMetrica clearStubs];
    });

    context(@"initWithAnalyticsProxy:", ^{

        beforeEach(^{
            bridge = [[AMPEventsReporterBridge alloc] initWithAnalyticsProxy:analyticsProxy];
        });

        it(@"Should store the provided analyticsProxy", ^{
            [[bridge.analyticsProxy should] beIdenticalTo:analyticsProxy];
        });

    });

    context(@"init", ^{

        it(@"Should use AMPAnalyticsProxy sharedInstance as analyticsProxy", ^{
            AMPAnalyticsProxy *sharedProxy = [AMPAnalyticsProxy nullMock];
            [AMPAnalyticsProxy stub:@selector(sharedInstance) andReturn:sharedProxy];

            bridge = [[AMPEventsReporterBridge alloc] init];

            [[bridge.analyticsProxy should] beIdenticalTo:sharedProxy];

            [AMPAnalyticsProxy clearStubs];
        });

    });

    context(@"reportEventWithType:name:value:environment:onFailure:", ^{

        NSUInteger const eventType = 42;
        NSString *const eventName = @"test_event";
        NSString *const eventValue = @"test_value";
        NSDictionary *const environment = @{ @"key" : @"value" };

        beforeEach(^{
            bridge = [[AMPEventsReporterBridge alloc] initWithAnalyticsProxy:analyticsProxy];
        });

        it(@"Should call AMAAppMetrica reportEventWithType:name:value:eventEnvironment:appEnvironment:extras:onFailure:", ^{
            [[AMAAppMetrica should] receive:@selector(reportEventWithType:name:value:eventEnvironment:appEnvironment:extras:onFailure:)
                             withArguments:theValue(eventType),
                                          eventName,
                                          eventValue,
                                          environment,
                                          nil,
                                          nil,
                                          nil];

            [bridge reportEventWithType:eventType
                                   name:eventName
                                  value:eventValue
                            environment:environment
                              onFailure:nil];
        });

        it(@"Should call activate on analyticsProxy", ^{
            [[analyticsProxy should] receive:@selector(activate)];

            [bridge reportEventWithType:eventType
                                   name:eventName
                                  value:eventValue
                            environment:environment
                              onFailure:nil];
        });

        it(@"Should call activate on analyticsProxy on each report call", ^{
            [[analyticsProxy should] receive:@selector(activate) withCount:2];

            [bridge reportEventWithType:eventType
                                   name:eventName
                                  value:eventValue
                            environment:environment
                              onFailure:nil];

            [bridge reportEventWithType:eventType
                                   name:eventName
                                  value:eventValue
                            environment:environment
                              onFailure:nil];
        });

        it(@"Should handle multiple sequential report calls", ^{
            NSUInteger const secondType = 99;
            NSString *const secondName = @"second_event";
            NSString *const secondValue = @"second_value";
            NSDictionary *const secondEnv = @{ @"k2" : @"v2" };

            [[AMAAppMetrica should] receive:@selector(reportEventWithType:name:value:eventEnvironment:appEnvironment:extras:onFailure:)
                             withArguments:theValue(eventType),
                                          eventName,
                                          eventValue,
                                          environment,
                                          nil,
                                          nil,
                                          nil];

            [bridge reportEventWithType:eventType
                                   name:eventName
                                  value:eventValue
                            environment:environment
                              onFailure:nil];

            [[AMAAppMetrica should] receive:@selector(reportEventWithType:name:value:eventEnvironment:appEnvironment:extras:onFailure:)
                             withArguments:theValue(secondType),
                                          secondName,
                                          secondValue,
                                          secondEnv,
                                          nil,
                                          nil,
                                          nil];

            [bridge reportEventWithType:secondType
                                   name:secondName
                                  value:secondValue
                            environment:secondEnv
                              onFailure:nil];
        });

    });

    context(@"initWithAnalyticsProxy: does not return nil", ^{

        it(@"Should return non-nil instance", ^{
            bridge = [[AMPEventsReporterBridge alloc] initWithAnalyticsProxy:analyticsProxy];
            [[bridge should] beNonNil];
        });

    });

    context(@"init does not return nil", ^{

        it(@"Should return non-nil instance", ^{
            AMPAnalyticsProxy *sharedProxy = [AMPAnalyticsProxy nullMock];
            [AMPAnalyticsProxy stub:@selector(sharedInstance) andReturn:sharedProxy];

            bridge = [[AMPEventsReporterBridge alloc] init];
            [[bridge should] beNonNil];

            [AMPAnalyticsProxy clearStubs];
        });

    });

});

SPEC_END
