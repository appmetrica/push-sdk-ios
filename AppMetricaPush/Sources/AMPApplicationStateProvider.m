
#import "AMPApplicationStateProvider.h"
#import "AMPApplication.h"

#import <AppMetricaPlatform/AppMetricaPlatform.h>

@interface AMPApplicationStateProvider ()

@property (nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation AMPApplicationStateProvider

- (instancetype)init
{
    return [self initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super init];
    if (self != nil) {
        _notificationCenter = notificationCenter;
    }
    return self;
}

- (void)dealloc
{
    [_notificationCenter removeObserver:self];
}

- (AMPApplicationState)currentApplicationState
{
    UIApplicationState state = [AMPApplication applicationState];
    switch (state) {
        case UIApplicationStateBackground:
        case UIApplicationStateInactive:
            return AMPApplicationStateBackground;
        case UIApplicationStateActive:
            return AMPApplicationStateForeground;
        default:
            return AMPApplicationStateUnknown;
    }
}

- (AMPApplicationState)userNotificationCenterPushApplicationState
{
    // TODO(https://nda.ya.ru/t/Lj80ddO2753k2q ): remove this workaround for target URLs in UNC-pushes
    return AMPApplicationStateBackground;
}

- (void)setDelegate:(id<AMPApplicationStateProviderDelegate>)delegate
{
    if (delegate != _delegate) {
        if (delegate == nil) {
            [self unsubscribeFromApplicationStateChanges];
        }
        if (_delegate == nil) {
            [self subscribeOnApplicationStateChanges];
        }
        _delegate = delegate;
    }
}

- (void)subscribeOnApplicationStateChanges
{
    if ([AMAPlatformDescription isExtension]) {
        return;
    }
    [self.notificationCenter addObserver:self
                                selector:@selector(applicationDidBecomeActive)
                                    name:UIApplicationDidBecomeActiveNotification
                                  object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(applicationWillResignActive)
                                    name:UIApplicationWillResignActiveNotification
                                  object:nil];
}

- (void)unsubscribeFromApplicationStateChanges
{
    [self.notificationCenter removeObserver:self];
}

- (void)applicationDidBecomeActive
{
    [self notifyStateChange:AMPApplicationStateForeground];
}

- (void)applicationWillResignActive
{
    [self notifyStateChange:AMPApplicationStateBackground];
}

- (void)notifyStateChange:(AMPApplicationState)state
{
    [self.delegate applicationStateProvider:self didChangeState:state];
}

@end
