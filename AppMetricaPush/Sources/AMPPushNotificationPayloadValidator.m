
#import "AMPPushNotificationPayloadValidator.h"
#import "AMPPushNotificationPayload.h"

@implementation AMPPushNotificationPayloadValidator

- (BOOL)isPayloadGenerallyValid:(AMPPushNotificationPayload *)payload
{
    return payload != nil;
}

- (BOOL)isPayloadValidForTracking:(AMPPushNotificationPayload *)payload
{
    BOOL isValid = [self isPayloadGenerallyValid:payload];
    isValid = isValid && payload.notificationID.length > 0;

    return isValid;
}

- (BOOL)isPayloadValidForURLOpening:(AMPPushNotificationPayload *)payload
{
    BOOL isValid = [self isPayloadGenerallyValid:payload];
    isValid = isValid && payload.silent == NO;
    isValid = isValid && payload.targetURL.length > 0;

    return isValid;
}

- (BOOL)isPayloadValidForUserDataProviding:(AMPPushNotificationPayload *)payload
{
    BOOL isValid = [self isPayloadGenerallyValid:payload];
    isValid = isValid && payload.userData != nil;

    return isValid;
}

@end
