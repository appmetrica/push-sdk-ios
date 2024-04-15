
#import <Foundation/Foundation.h>
#import "AMPUserNotificationCenterDelegate.h"

@class AMPUserNotificationCenterHandler;

@interface AMPUserNotificationCenterController : NSObject <AMPUserNotificationCenterDelegate>

- (instancetype)initWithHandler:(AMPUserNotificationCenterHandler *)handler;

+ (instancetype)sharedInstance;

@end
