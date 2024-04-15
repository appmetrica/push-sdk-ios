
#import <Kiwi/Kiwi.h>

#import "AMPTargetURLHandler.h"
#import "AMPManualExecutor.h"
#import "AMPCurrentQueueExecutor.h"

SPEC_BEGIN(AMPTargetURLHandlerTests)

describe(@"AMPTargetURLHandler", ^{

    AMPTargetURLHandler *__block handler = nil;
    UIApplication *__block sharedApplication = nil;
    BOOL __block blockExecutionCalled;

    beforeEach(^{
        sharedApplication = [UIApplication nullMock];
        [UIApplication stub:@selector(sharedApplication) andReturn:sharedApplication];
        blockExecutionCalled = NO;
    });

    context(@"URL opening", ^{
        AMPCurrentQueueExecutor *__block executor = nil;

        beforeEach(^{
            executor = [[AMPCurrentQueueExecutor alloc] init];
            handler = [[AMPTargetURLHandler alloc] initWithExecutor:executor];
            [executor stub:@selector(execute:) withBlock:^id(NSArray *params) {
                blockExecutionCalled = YES;
                return nil;
            }];
        });

        it(@"Should not open nil URL", ^{
            [handler handleURL:nil applicationState:AMPApplicationStateBackground];
            [[theValue(blockExecutionCalled) should] beNo];
        });

        it(@"Should not open invalid URL", ^{
            NSString *invalidURL = @"<not~an^URL>";
            [handler handleURL:invalidURL applicationState:AMPApplicationStateBackground];
            [[theValue(blockExecutionCalled) should] beNo];
        });

        it(@"Should not open URL in foreground", ^{
            [handler handleURL:@"https://ya.ru" applicationState:AMPApplicationStateForeground];
            [[theValue(blockExecutionCalled) should] beNo];
        });

        it(@"Should open valid URL in background", ^{
            [handler handleURL:@"https://ya.ru" applicationState:AMPApplicationStateBackground];
            [[theValue(blockExecutionCalled) should] beYes];
        });

    });

    context(@"Custom executor", ^{

        AMPManualExecutor *__block executor = nil;

        beforeEach(^{
            executor = [[AMPManualExecutor alloc] init];
            handler = [[AMPTargetURLHandler alloc] initWithExecutor:executor];
            [executor stub:@selector(executeAll) withBlock:^id(NSArray *params) {
                blockExecutionCalled = YES;
                return nil;
            }];
        });

        NSString *const URLString = @"https://ya.ru";
        AMPApplicationState const state = AMPApplicationStateBackground;

        it(@"Should not open URL outside of executor", ^{
            [handler handleURL:URLString applicationState:state];
            [[theValue(blockExecutionCalled) should] beNo];
        });

        it(@"Should open URL with default executor", ^{
            [handler handleURL:URLString applicationState:state];
            [executor executeAll];
            [[theValue(blockExecutionCalled) should] beYes];
        });

        it(@"Should open URL with custom executor", ^{
            AMPManualExecutor *customExecutor = [[AMPManualExecutor alloc] init];
            [customExecutor stub:@selector(executeAll) withBlock:^id(NSArray *params) {
                blockExecutionCalled = YES;
                return nil;
            }];
            handler.executor = customExecutor;
            [handler handleURL:URLString applicationState:state];
            [customExecutor executeAll];
            [[theValue(blockExecutionCalled) should] beYes];
        });

        it(@"Should store custom executor", ^{
            AMPManualExecutor *customExecutor = [[AMPManualExecutor alloc] init];
            handler.executor = customExecutor;
            
            [[(AMPManualExecutor *)handler.executor should] equal:customExecutor];
        });

    });
    
});

SPEC_END
