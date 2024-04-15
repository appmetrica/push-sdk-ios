
#import <Kiwi/Kiwi.h>

#import "AMPDispatchQueueWhenActiveStateExecutor.h"

@interface AMPDispatchQueueWhenActiveStateExecutor (Test)

- (void) executeAll;

@end

SPEC_BEGIN(AMPDispatchQueueWhenActiveStateExecutorTests)

describe(@"AMPDispatchQueueWhenActiveStateExecutor", ^{

    NSTimeInterval const timeout = 1.0;

    AMPDispatchQueueWhenActiveStateExecutor *__block executor = nil;
    AMPApplicationStateProvider *__block applicationStateProvider;

    beforeEach(^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        applicationStateProvider = [AMPApplicationStateProvider nullMock];
        [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateForeground)];
        executor = [[AMPDispatchQueueWhenActiveStateExecutor alloc] initWithQueue:queue
                                                         applicationStateProvider:applicationStateProvider];
    });

    it(@"Should raise on nil block", ^{
        [[theBlock(^{
            [executor execute:nil];
        }) should] raiseWithName:@"NSInternalInconsistencyException"];
    });

    it(@"Should not execute block synchronically", ^{
        BOOL __block executed = NO;
        [executor execute:^{
            [NSThread sleepForTimeInterval:timeout];
            executed = YES;
        }];
        [[theValue(executed) should] beNo];
    });

    it(@"Should not execute when background state", ^{
        [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateBackground)];
        BOOL __block executed = NO;
        [executor execute:^{
            [NSThread sleepForTimeInterval:timeout];
            executed = YES;
        }];

        KWFutureObject *future = expectFutureValue(theValue(executed));
        [[future shouldNotEventuallyBeforeTimingOutAfter(timeout)] beYes];
    });

    it(@"Should execute all blocks", ^{
        [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateBackground)];
        BOOL __block executed1 = NO;
        BOOL __block executed2 = NO;
        [executor execute:^{
            [NSThread sleepForTimeInterval:timeout / 2];
            executed1 = YES;
        }];
        [executor execute:^{
            [NSThread sleepForTimeInterval:timeout / 2];
            executed2 = YES;
        }];
        [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateForeground)];
        [executor executeAll];

        KWFutureObject *future1 = expectFutureValue(theValue(executed1));
        [[future1 shouldEventuallyBeforeTimingOutAfter(timeout)] beYes];
        KWFutureObject *future2 = expectFutureValue(theValue(executed2));
        [[future2 shouldEventuallyBeforeTimingOutAfter(timeout)] beYes];
    });
});

SPEC_END

