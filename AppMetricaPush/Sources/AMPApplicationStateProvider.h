
#import "AMPApplicationState.h"

@class AMPApplicationStateProvider;

@protocol AMPApplicationStateProviderDelegate <NSObject>

- (void)applicationStateProvider:(AMPApplicationStateProvider *)applicationStateProvider
                  didChangeState:(AMPApplicationState)state;

@end

@interface AMPApplicationStateProvider : NSObject

@property (nonatomic, weak) id<AMPApplicationStateProviderDelegate> delegate;

@property (nonatomic, assign, readonly) AMPApplicationState userNotificationCenterPushApplicationState;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter;

- (AMPApplicationState)currentApplicationState;

@end
