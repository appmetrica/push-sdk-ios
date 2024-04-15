
#import <Foundation/Foundation.h>

@class AMPPushNotificationPayload;

@interface AMPPushNotificationPayloadParser : NSObject

- (AMPPushNotificationPayload *)pushNotificationPayloadFromDictionary:(NSDictionary *)dictionary;

@end
