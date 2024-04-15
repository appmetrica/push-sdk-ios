
#import <Kiwi/Kiwi.h>

#import "AMPLibraryAnalyticsTracker.h"
#import "AMPLibraryAnalyticsEnvironmentProvider.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreExtension/AppMetricaCoreExtension.h>

@interface AMPLibraryAnalyticsTracker (Tests)

- (instancetype)initWithEnvironmentProvider:(AMPLibraryAnalyticsEnvironmentProvider *)provider;

- (id<AMAAppMetricaReporting>)reporter;

@end

SPEC_BEGIN(AMPLibraryAnalyticsTrackerTests)

describe(@"AMPLibraryAnalyticsTracker", ^{

    NSDictionary *const commonEnvironment = @{ @"env_foo" : @"env_bar" };

    AMPLibraryAnalyticsEnvironmentProvider __block *environmentProvider = nil;
    AMPLibraryAnalyticsTracker __block *tracker = nil;

    beforeEach(^{
        environmentProvider = [AMPLibraryAnalyticsEnvironmentProvider nullMock];
        [environmentProvider stub:@selector(commonEnvironment) andReturn:commonEnvironment];

        tracker = [[AMPLibraryAnalyticsTracker alloc] initWithEnvironmentProvider:environmentProvider];
    });

    it(@"Should get shared reporter with proper key", ^{
        [[AMAAppMetrica should] receive:@selector(extendedReporterForApiKey:)
                          withArguments:@"0e5e9c33-f8c3-4568-86c5-2e4f57523f72"];
        [tracker reporter];
    });

    context(@"With reporter", ^{

        KWMock __block *reporter = nil;

        beforeEach(^{
            reporter = [KWMock nullMockForProtocol:@protocol(AMAAppMetricaReporting)];
            [tracker stub:@selector(reporter) andReturn:reporter];
        });

        context(@"Report event", ^{

            it(@"Should report event to shared reporter with proper name", ^{
                NSString *eventName = @"NAME";
                [[reporter should] receive:@selector(reportEvent:parameters:onFailure:)
                             withArguments:eventName, kw_any(), kw_any()];
                [tracker reportEventWithName:eventName parameters:nil];
            });

            it(@"Should report event to shared reporter with paramers", ^{
                NSDictionary *parameters = @{ @"foo" : @"bar" };
                KWCaptureSpy *spy = [reporter captureArgument:@selector(reportEvent:parameters:onFailure:) atIndex:1];
                [tracker reportEventWithName:nil parameters:parameters];
                [[spy.argument[@"foo"] should] equal:@"bar"];
            });

            it(@"Should append environment parameters", ^{
                KWCaptureSpy *spy = [reporter captureArgument:@selector(reportEvent:parameters:onFailure:) atIndex:1];
                [tracker reportEventWithName:nil parameters:nil];
                [[spy.argument[@"env_foo"] should] equal:@"env_bar"];
            });

        });

        it(@"Should resume session", ^{
            [[reporter should] receive:@selector(resumeSession)];
            [tracker resumeSession];
        });
    });
    
});

SPEC_END
