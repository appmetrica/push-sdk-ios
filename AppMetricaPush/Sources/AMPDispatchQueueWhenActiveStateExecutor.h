
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>
#import "AMPApplicationStateProvider.h"

@interface AMPDispatchQueueWhenActiveStateExecutor : NSObject <AMAAsyncExecuting>

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (instancetype)initWithQueue:(dispatch_queue_t)queue
     applicationStateProvider:(AMPApplicationStateProvider *)applicationStateProvider NS_DESIGNATED_INITIALIZER;

@end
