
#import <Foundation/Foundation.h>
#import "AMPPushProcessor.h"

@class AMPPushNotificationPayload;

@protocol AMPLazyPushProviding<NSObject, AMPPushProcessor>
- (void)processNotificationContent:(UNNotificationContent *)content
                       withPayload:(AMPPushNotificationPayload *)payload
                     resultHandler:(AMPPushProcessorCallback)resultHandler;
@end
