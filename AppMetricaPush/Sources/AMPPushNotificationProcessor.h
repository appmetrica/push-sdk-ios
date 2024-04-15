
#import <Foundation/Foundation.h>
#import "AMPPushProcessor.h"

@interface AMPPushNotificationProcessor : NSObject <AMPPushProcessor>

+ (instancetype)sharedInstance;

@end
