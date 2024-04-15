
#import <Foundation/Foundation.h>
#import "AMPPushProcessor.h"
#import "AMPLazyPushProviding.h"

@class AMPPushNotificationPayload;

@interface AMPLazyPushProcessor : NSObject <AMPLazyPushProviding>

+ (instancetype)sharedInstance;

- (void)processNotificationContent:(UNNotificationContent *)content
                       withPayload:(AMPPushNotificationPayload *)payload
                     resultHandler:(AMPPushProcessorCallback)resultHandler;

@end
