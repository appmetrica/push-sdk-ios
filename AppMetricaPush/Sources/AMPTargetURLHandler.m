
#import "AMPTargetURLHandler.h"
#import "AMPApplication.h"
#import "NSURL+EncodingCharactersInit.h"
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

@implementation AMPTargetURLHandler

- (instancetype)initWithExecutor:(id<AMAAsyncExecuting>)executor
{
    self = [super init];
    if (self != nil) {
        _executor = executor;
    }
    return self;
}

- (void)handleURL:(NSString *)URLString applicationState:(AMPApplicationState)applicationState
{
    if (applicationState == AMPApplicationStateBackground && URLString.length > 0) {
        NSURL *URL = [NSURL URLWithEncodingCharactersString:URLString];
        [self openURL:URL];
    }
}

- (void)openURL:(NSURL *)URL
{
    if (URL == nil) {
        return;
    }

    [self.executor execute:^{
        [AMPApplication openURL:URL];
    }];
}

@end
