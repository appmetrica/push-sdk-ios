
#import "AMPPendingNotifyStrategyDelegateMock.h"

@implementation AMPPendingNotifyStrategyDelegateMock

- (void)pendingNotificationStrategyDidRequestPush:(AMPPendingNotificationStrategy *)strategy
{
    [self.wantPushExpectation fulfill];
}

@end
