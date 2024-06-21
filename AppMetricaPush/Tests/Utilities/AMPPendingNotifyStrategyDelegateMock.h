
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "AMPPendingNotificationStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface AMPPendingNotifyStrategyDelegateMock : NSObject<AMPPendingNotificationStrategyDelegate>

@property (nonatomic, nullable, strong) XCTestExpectation *wantPushExpectation;

@end

NS_ASSUME_NONNULL_END
