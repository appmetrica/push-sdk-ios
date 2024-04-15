
#import "AMPDispatchQueueWhenActiveStateExecutor.h"

#import <UIKit/UIKit.h>

@interface AMPDispatchQueueWhenActiveStateExecutor ()

@property (nonatomic, strong, readonly) AMPApplicationStateProvider *applicationStateProvider;
@property (nonatomic, strong, readonly) NSMutableArray<dispatch_block_t> *blockArray;

@end

@implementation AMPDispatchQueueWhenActiveStateExecutor

- (instancetype)init
{
    return [self initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    return [self initWithQueue:queue
      applicationStateProvider:[[AMPApplicationStateProvider alloc] init]];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
     applicationStateProvider:(AMPApplicationStateProvider *)applicationStateProvider
{
    self = [super init];
    if (self != nil) {
        _queue = queue ?: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        _applicationStateProvider = applicationStateProvider ?: [[AMPApplicationStateProvider alloc] init];
        _blockArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(executeAll)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)execute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    if (block != nil) {
        @synchronized (self) {
            [self.blockArray addObject:block];
        }
        [self executeAll];
    }
}

- (void)executeAll
{
    if ([self.applicationStateProvider currentApplicationState] == AMPApplicationStateForeground) {
        NSArray<dispatch_block_t> *blocks = nil;
        @synchronized (self) {
            blocks = [self.blockArray copy];
            [self.blockArray removeAllObjects];
        }
        for (dispatch_block_t block in blocks) {
            dispatch_async(self.queue, block);
        }
    }
}

@end
