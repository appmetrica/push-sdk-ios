
#import <Foundation/Foundation.h>

@class AMPPushNotificationPayload;

@interface AMPPushNotificationPayloadValidator : NSObject

- (BOOL)isPayloadGenerallyValid:(AMPPushNotificationPayload *)payload;
- (BOOL)isPayloadValidForTracking:(AMPPushNotificationPayload *)payload;
- (BOOL)isPayloadValidForURLOpening:(AMPPushNotificationPayload *)payload;
- (BOOL)isPayloadValidForUserDataProviding:(AMPPushNotificationPayload *)payload;

@end
