
#import "AMPCurrentQueueExecutor.h"

@implementation AMPCurrentQueueExecutor

- (void)execute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    if (block != nil) {
        block();
    }
}

@end
