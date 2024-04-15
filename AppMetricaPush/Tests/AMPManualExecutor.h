
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

@interface AMPManualExecutor : NSObject <AMAAsyncExecuting>

- (void)executeNextBlock;
- (void)executeAll;

@end
