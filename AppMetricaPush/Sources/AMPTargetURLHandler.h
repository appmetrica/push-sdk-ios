
#import "AMPApplicationState.h"

@protocol AMAAsyncExecuting;

@interface AMPTargetURLHandler : NSObject

@property (nonatomic, strong) id<AMAAsyncExecuting> executor;

- (instancetype)initWithExecutor:(id<AMAAsyncExecuting>)executor;

- (void)handleURL:(NSString *)URLString applicationState:(AMPApplicationState)applicationState;

@end
