
#import "AMPPendingNotificationStrategy.h"
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

static NSTimeInterval kDefaultMaxInterval = 2 * 60;
static NSUInteger kMaxPendingPush = 10;

@interface AMPPendingNotificationStrategy ()

@property (nonatomic) NSUInteger pushNotificationCounter;
@property (nonatomic) BOOL delayScheduled;

@end

@implementation AMPPendingNotificationStrategy

- (instancetype) initWithExecutor:(id<AMACancelableExecuting>)executor
{
    self = [super init];
    if (self) {
        _maxInterval = kDefaultMaxInterval;
        _maxPendingPushes = kMaxPendingPush;
        _executor = executor;
    }
    return self;
}

- (void)handlePushNotification 
{
    BOOL shouldExecute = NO;
    BOOL shouldCallDelegate = NO;
    @synchronized (self) {
        if (self.delayScheduled == NO) {
            shouldExecute = YES;
        }
        self.pushNotificationCounter += 1;
        shouldCallDelegate = self.pushNotificationCounter >= self.maxPendingPushes;
        
        if (shouldCallDelegate == NO && shouldExecute) {
            self.delayScheduled = YES;
        }
    }
    
    if (shouldCallDelegate) {
        [self.delegate pendingNotificationStrategyDidRequestPush:self];
    }
    else if (shouldExecute) {
        __weak typeof(self) weakSelf = self;
        [self.executor executeAfterDelay:self.maxInterval block:^{
            [weakSelf notifyIfNeeded];
        }];
    }
}

- (void)clear
{
    [self.executor cancelDelayed];
    @synchronized (self) {
        self.delayScheduled = NO;
        self.pushNotificationCounter = 0;
    }
}

- (void)notifyIfNeeded
{
    BOOL shouldCallDelegate = NO;
    @synchronized (self) {
        shouldCallDelegate = self.pushNotificationCounter > 0;
        
        self.pushNotificationCounter = 0;
        self.delayScheduled = NO;
    }
    
    if (shouldCallDelegate) {
        [self.delegate pendingNotificationStrategyDidRequestPush:self];
    }
}

@end
