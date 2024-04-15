
#import <Kiwi/Kiwi.h>

#import "AMPApplicationStateProvider.h"

SPEC_BEGIN(AMPApplicationStateProviderTests)

describe(@"AMPApplicationStateProvider", ^{

    NSNotificationCenter *__block notificationCenter = nil;
    NSObject<AMPApplicationStateProviderDelegate> *__block delegate = nil;
    AMPApplicationStateProvider *__block provider = nil;

    beforeEach(^{
        notificationCenter = [NSNotificationCenter nullMock];
        delegate = [KWMock nullMockForProtocol:@protocol(AMPApplicationStateProviderDelegate)];
        provider = [[AMPApplicationStateProvider alloc] initWithNotificationCenter:notificationCenter];
    });

    context(@"Application in foreground", ^{
        UIApplication *__block sharedApplication = nil;

        beforeEach(^{
            sharedApplication = [UIApplication nullMock];
            [UIApplication stub:@selector(sharedApplication) andReturn:sharedApplication];
        });

        it(@"Should return background state for inactive current application state", ^{
            [sharedApplication stub:@selector(applicationState) andReturn:theValue(UIApplicationStateInactive)];
            [[expectFutureValue(theValue([provider currentApplicationState])) shouldEventuallyBeforeTimingOutAfter(1.0)]
                equal:theValue(AMPApplicationStateBackground)];
        });

        it(@"Should return background state for background current application state", ^{
            [sharedApplication stub:@selector(applicationState) andReturn:theValue(UIApplicationStateBackground)];
            [[expectFutureValue(theValue([provider currentApplicationState])) shouldEventuallyBeforeTimingOutAfter(1.0)]
                equal:theValue(AMPApplicationStateBackground)];
        });

        it(@"Should return foreground state for active current application state", ^{
            [sharedApplication stub:@selector(applicationState) andReturn:theValue(UIApplicationStateActive)];
            [[expectFutureValue(theValue([provider currentApplicationState])) shouldEventuallyBeforeTimingOutAfter(1.0)]
                equal:theValue(AMPApplicationStateForeground)];
        });

        it(@"Should return unknown state for unknown application state value", ^{
            [sharedApplication stub:@selector(applicationState) andReturn:theValue(23)];
            [[expectFutureValue(theValue([provider currentApplicationState])) shouldEventuallyBeforeTimingOutAfter(1.0)]
                equal:theValue(AMPApplicationStateUnknown)];
        });

        it(@"Should return background state for on-user-notification-center push application state", ^{
            [[theValue(provider.userNotificationCenterPushApplicationState) should]
                equal:theValue(AMPApplicationStateBackground)];
        });

    });

    context(@"Delegate", ^{

        it(@"Should subscribe for did become active notification", ^{
            [[notificationCenter should] receive:@selector(addObserver:selector:name:object:)
                                   withArguments:provider, kw_any(), UIApplicationDidBecomeActiveNotification, nil];
            provider.delegate = delegate;
        });
        it(@"Should subscribe for will resign active notification", ^{
            [[notificationCenter should] receive:@selector(addObserver:selector:name:object:)
                                   withArguments:provider, kw_any(), UIApplicationWillResignActiveNotification, nil];
            provider.delegate = delegate;
        });

        context(@"Delegate set", ^{
            SEL __block didBecomeActiveSelector = nil;
            SEL __block willResignActiveSelector = nil;
            beforeEach(^{
                [notificationCenter stub:@selector(addObserver:selector:name:object:) withBlock:^id(NSArray *params) {
                    NSString *notificationName = params[2];
                    if ([notificationName isEqual:UIApplicationDidBecomeActiveNotification]) {
                        didBecomeActiveSelector = NSSelectorFromString(params[1]);
                    }
                    else if ([notificationName isEqual:UIApplicationWillResignActiveNotification]) {
                        willResignActiveSelector = NSSelectorFromString(params[1]);
                    }
                    else {
                        fail(@"Subscribed to unknown notification: %@", notificationName);
                    }
                    return nil;
                }];
                provider.delegate = delegate;
            });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            it(@"Should report about entering foreground", ^{
                [[delegate should] receive:@selector(applicationStateProvider:didChangeState:)
                             withArguments:provider, theValue(AMPApplicationStateForeground)];
                [provider performSelector:didBecomeActiveSelector];
            });
            it(@"Should report about entering background", ^{
                [[delegate should] receive:@selector(applicationStateProvider:didChangeState:)
                             withArguments:provider, theValue(AMPApplicationStateBackground)];
                [provider performSelector:willResignActiveSelector];
            });
#pragma clang diagnostic pop

            it(@"Should onsubscribe from notifications on setting delegate to nil", ^{
                [[notificationCenter should] receive:@selector(removeObserver:) withArguments:provider];
                provider.delegate = nil;
            });
        });

    });
    
});

SPEC_END
