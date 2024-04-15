
#import <Foundation/Foundation.h>
#import "AMPPushProcessor.h"

@class UNNotificationContent;

@interface AMPPushController : NSObject <AMPPushProcessor>

+ (instancetype)sharedInstance;

@end
