
#import <Kiwi/Kiwi.h>

#import "AMPEventsReporter.h"
#import "AMPEventsReporterBridgeMock.h"
#import "AMPTokenEvent.h"
#import "AMPTokenEventValueSerializer.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

SPEC_BEGIN(AMPEventsReporterTests)

describe(@"AMPEventsReporter", ^{

    AMPEventsReporter *__block reporter = nil;

    AMPEventsReporterBridgeMock *__block bridge = nil;

    beforeEach(^{
        bridge = [[AMPEventsReporterBridgeMock alloc] init];
        reporter = [[AMPEventsReporter alloc] initWithEventsReporterBridge:bridge];
    });

    context(@"Metrica error wrapping", ^{

        it(@"Should wrap nil error on token reporting", ^{
            NSError *__block resultError = nil;
            [reporter reportDeviceTokenWithValue:@"" environment:@{} onFailure:^(NSError *error) {
                resultError = error;
            }];
            bridge.lastOnFailureBlock(nil);
            [[resultError should] beNonNil];
        });

        it(@"Should wrap nil error on notification reporting", ^{
            NSError *__block resultError = nil;
            [reporter reportPushNotification:@{} environment:@{} onFailure:^(NSError *error) {
                resultError = error;
            }];
            bridge.lastOnFailureBlock(nil);
            [[resultError should] beNonNil];
        });

    });

    context(@"Device Token", ^{

        NSString *const token = @"token";
        NSDictionary *const environment = @{ @"a" : @"b" };
        AMPTokenEvent *tokenModel = [[AMPTokenEvent alloc] initWithToken:token enabled:YES notifications:nil];
        NSString *const eventValue = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];

        beforeEach(^{
            [reporter reportDeviceTokenWithValue:eventValue environment:environment onFailure:nil];
        });

        it(@"Should send event with proper type", ^{
            [[theValue(bridge.lastReportedEventType) should] equal:theValue(14)];
        });

        it(@"Should send event with proper name", ^{
            [[bridge.lastReportedEventName should] equal:@"push_token"];
        });

        it(@"Should send event with proper value", ^{
            [[bridge.lastReportedEventValue should] equal:eventValue];
        });

        it(@"Should send event with proper environment", ^{
            [[bridge.lastReportedEventEnvironment should] equal:environment];
        });

        it(@"Should call sendEventsBuffer after sending event", ^{
            [[AMAAppMetrica should] receive:@selector(sendEventsBuffer)];
            [reporter reportDeviceTokenWithValue:eventValue environment:environment onFailure:nil];
        });

    });

    context(@"Notification", ^{

        NSDictionary *const notification = @{ @"n" : @"d" };
        NSDictionary *const environment = @{ @"a" : @"b" };

        beforeEach(^{
            [reporter reportPushNotification:notification environment:environment onFailure:nil];
        });

        it(@"Should send event with proper type", ^{
            [[theValue(bridge.lastReportedEventType) should] equal:theValue(15)];
        });

        it(@"Should send event with proper name", ^{
            [[bridge.lastReportedEventName should] equal:@"push_notification"];
        });

        it(@"Should send event with JSON representation of notification as value", ^{
            [[bridge.lastReportedEventValue should] equal:@"{\"n\":\"d\"}"];
        });

        it(@"Should send event with proper environment", ^{
            [[bridge.lastReportedEventEnvironment should] equal:environment];
        });

        it(@"Should call sendEventsBuffer after sending event", ^{
            [[AMAAppMetrica should] receive:@selector(sendEventsBuffer)];
            [reporter reportPushNotification:notification environment:environment onFailure:nil];
        });

    });

    context(@"Reporter not activated validation", ^{

        it(@"Should not determine error with different domain", ^{
            NSError *error = [NSError errorWithDomain:@"com.other.domain"
                                                 code:AMAAppMetricaEventErrorCodeInitializationError
                                             userInfo:nil];
            BOOL result = [reporter isReporterNotActivatedError:error];
            [[theValue(result) should] beNo];
        });

        it(@"Should not determine error with different code", ^{
            NSError *error = [NSError errorWithDomain:kAMAAppMetricaErrorDomain
                                                 code:-1
                                             userInfo:nil];
            BOOL result = [reporter isReporterNotActivatedError:error];
            [[theValue(result) should] beNo];
        });

        it(@"Should determine metrica not activated error", ^{
            
            NSError *error = [NSError errorWithDomain:kAMAAppMetricaErrorDomain
                                                 code:AMAAppMetricaEventErrorCodeInitializationError
                                             userInfo:nil];
            BOOL result = [reporter isReporterNotActivatedError:error];
            [[theValue(result) should] beYes];
        });

    });

    context(@"Send events buffer", ^{

        it(@"Should call sendEventsBuffer", ^{
            [[AMAAppMetrica should] receive:@selector(sendEventsBuffer)];
            [reporter sendEventsBuffer];
        });

    });
    
});

SPEC_END
