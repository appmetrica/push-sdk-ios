#import <XCTest/XCTest.h>

#import "AMPPendingNotificationStrategy.h"
#import "AMPPendingNotifyStrategyDelegateMock.h"

#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

static NSTimeInterval kTestDefaultTimeout = 10;
static NSTimeInterval kBigIntervalTimeout = 1000;

@interface AMPPendingNotificationStrategyTests : XCTestCase

@property (nonatomic, strong) AMACancelableDelayedExecutor *executor;

@property (nonatomic, strong) AMPPendingNotifyStrategyDelegateMock *mockDelegate;
@property (nonatomic, strong) AMPPendingNotificationStrategy *strategy;

@end

@implementation AMPPendingNotificationStrategyTests

- (void)setUp
{
    self.executor = [[AMACancelableDelayedExecutor alloc] initWithIdentifier:self];
    
    self.mockDelegate = [[AMPPendingNotifyStrategyDelegateMock alloc] init];
    self.strategy = [[AMPPendingNotificationStrategy alloc] initWithExecutor:self.executor];
    self.strategy.delegate = self.mockDelegate;
}

- (void)testNoBuffer
{
    self.strategy.maxInterval = 0;
    self.strategy.maxPendingPushes = 0;
    
    self.mockDelegate.wantPushExpectation =  [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should be called"];
    
    [self.strategy handlePushNotification];
    
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
}

- (void)testPendingPushes
{
    self.strategy.maxInterval = kBigIntervalTimeout;
    self.strategy.maxPendingPushes = 2;
    
    self.mockDelegate.wantPushExpectation =  [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should not be called"];
    self.mockDelegate.wantPushExpectation.inverted = YES;
    
    [self.strategy handlePushNotification];
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
    
    self.mockDelegate.wantPushExpectation = [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should be called"];
    
    [self.strategy handlePushNotification];
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
    
}

- (void)testTimeout
{
    self.strategy.maxInterval = kTestDefaultTimeout * 2;
    self.strategy.maxPendingPushes = 10000;
    
    self.mockDelegate.wantPushExpectation =  [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should not be called"];
    self.mockDelegate.wantPushExpectation.inverted = YES;
    
    [self.strategy handlePushNotification];
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
    
    self.mockDelegate.wantPushExpectation = [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should be called"];
    
    [self.strategy handlePushNotification];
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
}

- (void)testClear
{
    self.strategy.maxInterval = kBigIntervalTimeout;
    self.strategy.maxPendingPushes = 2;
    
    self.mockDelegate.wantPushExpectation =  [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should not be called"];
    self.mockDelegate.wantPushExpectation.inverted = YES;
    
    [self.strategy handlePushNotification];
    [self.strategy clear];
    [self.strategy handlePushNotification];
    
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
    
    self.mockDelegate.wantPushExpectation =  [self expectationWithDescription:@"pendingNotifyStrategyWantPush: should be called"];
    
    [self.strategy handlePushNotification];
    
    [self waitForExpectations:@[self.mockDelegate.wantPushExpectation] timeout:kTestDefaultTimeout];
}

@end
