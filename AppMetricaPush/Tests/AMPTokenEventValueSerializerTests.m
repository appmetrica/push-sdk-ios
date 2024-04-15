
#import <Kiwi/Kiwi.h>

#import "AMPTokenEvent.h"
#import "AMPTokenEventModelProvider.h"
#import "AMPTokenEventValueSerializer.h"

SPEC_BEGIN(AMPTokenEventValueSerializerTests)

describe(@"AMPEventsController", ^{

    NSString *(^stringWithBool)(BOOL) = ^NSString *(BOOL boolValue) {
        return boolValue ? @"true" : @"false";
    };

    NSString *(^serializedModel)(NSString *, BOOL, BOOL, BOOL, BOOL) = ^NSString *(NSString *token,
                                                                                   BOOL enabled,
                                                                                   BOOL badgeEnabled,
                                                                                   BOOL soundEnabled,
                                                                                   BOOL alertEnabled) {
        return [NSString stringWithFormat:@"{\"token\":\"%@\","
                                            "\"notifications_status\":{"
                                                "\"enabled\":%@,"
                                                "\"type\":{"
                                                    "\"badge\":{"
                                                        "\"enabled\":%@"
                                                    "},"
                                                    "\"sound\":{"
                                                        "\"enabled\":%@"
                                                    "},"
                                                    "\"alert\":{"
                                                        "\"enabled\":%@"
                                                    "}"
                                                "}"
                                            "}"
                                        "}",
                token,
                stringWithBool(enabled),
                stringWithBool(badgeEnabled),
                stringWithBool(soundEnabled),
                stringWithBool(alertEnabled)];
    };

    context(@"Token model serializer", ^{

        NSString *const tokenName = @"token";
        UIUserNotificationSettings *__block currentUserNotificationSettings = nil;

        beforeEach(^{
            UIApplication *application = [UIApplication nullMock];
            [UIApplication stub:@selector(sharedApplication) andReturn:application];
            currentUserNotificationSettings = [UIUserNotificationSettings nullMock];
            [application stub:@selector(currentUserNotificationSettings) andReturn:currentUserNotificationSettings];
        });

        it(@"Should have enabled false if notification are disabled", ^{
            [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(0)];
            NSString *__block serializerJson = nil;
            NSString *validJson = serializedModel(tokenName, NO, NO, NO, NO);
            [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName block:^(AMPTokenEvent *tokenModel) {
                serializerJson = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];
            }];
            [[expectFutureValue(serializerJson) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:validJson];
        });

        it(@"Should have badge enabled true if UIUserNotificationTypeBadge enabled", ^{
            [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeBadge)];
            NSString *__block serializerJson = nil;
            NSString *validJson = serializedModel(tokenName, YES, YES, NO, NO);
            [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName block:^(AMPTokenEvent *tokenModel) {
                serializerJson = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];
            }];
            [[expectFutureValue(serializerJson) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:validJson];
        });

        it(@"Should have sound enabled true if UIUserNotificationTypeSound enabled", ^{
            [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeSound)];
            NSString *__block serializerJson = nil;
            NSString *validJson = serializedModel(tokenName, YES, NO, YES, NO);
            [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName block:^(AMPTokenEvent *tokenModel) {
                serializerJson = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];
            }];
            [[expectFutureValue(serializerJson) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:validJson];
        });

        it(@"Should have alert enabled true if UIUserNotificationTypeAlert enabled", ^{
            [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeAlert)];
            NSString *__block serializerJson = nil;
            NSString *validJson = validJson = serializedModel(tokenName, YES, NO, NO, YES);
            [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName block:^(AMPTokenEvent *tokenModel) {
                serializerJson = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];
            }];
            [[expectFutureValue(serializerJson) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:validJson];
        });

    });

});

SPEC_END
