
#import "AMPManualExecutor.h"

@interface AMPManualExecutor ()

@property (nonatomic, strong, readonly) NSMutableArray *blocks;

@end

@implementation AMPManualExecutor

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _blocks = [NSMutableArray array];
    }
    return self;
}

- (void)execute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    if (block != nil) {
        @synchronized (self) {
            [self.blocks addObject:block];
        }
    }
}

- (void)executeNextBlock
{
    dispatch_block_t block = nil;
    @synchronized (self) {
        block = [self.blocks firstObject];
        if (block != nil) {
            [self.blocks removeObjectAtIndex:0];
        }
    }

    if (block != nil) {
        block();
    }
}

- (void)executeAll
{
    NSArray *blocksToExecute = nil;
    @synchronized (self) {
        blocksToExecute = [self.blocks copy];
        [self.blocks removeAllObjects];
    }

    for (dispatch_block_t block in blocksToExecute) {
        block();
    }
}

@end
