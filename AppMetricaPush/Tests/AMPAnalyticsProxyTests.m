#import <Kiwi/Kiwi.h>
#import "AMPAnalyticsProxy.h"

@import AppMetricaLibraryAdapter;

@interface AMPAnalyticsProxy (Tests)
@property BOOL isActivateCalled;
@end

SPEC_BEGIN(AMPAnalyticsProxyTests)

describe(@"AMPAnalyticsProxy", ^{

    AMPAnalyticsProxy __block *proxy = nil;
    AMAAnalyticsLibraryAdapter __block *libraryAdapter = nil;

    beforeEach(^{
        libraryAdapter = [AMAAnalyticsLibraryAdapter nullMock];
        [AMAAnalyticsLibraryAdapter stub:@selector(sharedInstance) andReturn:libraryAdapter];

        proxy = [[AMPAnalyticsProxy alloc] init];
    });
    afterEach(^{
        [AMAAnalyticsLibraryAdapter clearStubs];
    });

    context(@"Shared instance", ^{

        it(@"Should return the same instance", ^{
            AMPAnalyticsProxy *first = [AMPAnalyticsProxy sharedInstance];
            AMPAnalyticsProxy *second = [AMPAnalyticsProxy sharedInstance];
            [[first should] beIdenticalTo:second];
        });

    });

    context(@"Activate", ^{

        it(@"Should call activate on AMAAnalyticsLibraryAdapter sharedInstance", ^{
            [[libraryAdapter should] receive:@selector(activate)];
            [proxy activate];
        });

        it(@"Should activate only once on multiple calls", ^{
            [[libraryAdapter should] receive:@selector(activate)];
            [proxy activate];
            [proxy activate];
            [proxy activate];
        });

        it(@"Should not activate again if already activated", ^{
            [proxy activate];
            [[libraryAdapter shouldNot] receive:@selector(activate)];
            [proxy activate];
        });

        it(@"Should set isActivatedCalled to YES after first activation", ^{
            [proxy activate];
            [[theValue(proxy.isActivateCalled) should] beYes];
        });

        it(@"Should not activate before activate is called", ^{
            [[libraryAdapter shouldNot] receive:@selector(activate)];
        });

        context(@"Thread safety", ^{

            it(@"Should activate exactly once when called from multiple threads concurrently", ^{
                __block NSInteger activationCount = 0;
                [libraryAdapter stub:@selector(activate) withBlock:^id(NSArray *params) {
                    @synchronized (proxy) {
                        activationCount++;
                    }
                    return nil;
                }];

                dispatch_group_t group = dispatch_group_create();
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

                for (NSInteger i = 0; i < 10; i++) {
                    dispatch_group_async(group, queue, ^{
                        [proxy activate];
                    });
                }

                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

                [[theValue(activationCount) should] equal:theValue(1)];
            });

        });

    });

});

SPEC_END

