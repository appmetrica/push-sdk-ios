
#import <Foundation/Foundation.h>
#import "AMPUserNotificationCenterHandling.h"

@class AMPPushNotificationController;

@interface AMPUserNotificationCenterHandler : NSObject <AMPUserNotificationCenterHandling>

- (instancetype)initWithPushNotificationController:(AMPPushNotificationController *)controller;

+ (instancetype)sharedInstance;

@end
