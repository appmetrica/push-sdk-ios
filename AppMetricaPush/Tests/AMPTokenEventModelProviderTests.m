
#import <Kiwi/Kiwi.h>

#import "AMPTokenEvent.h"
#import "AMPTokenEventModelProvider.h"
#import "AMPSubscribedNotification.h"

SPEC_BEGIN(AMPTokenEventModelProviderTests)

describe(@"AMPEventsController", ^{

    NSString *const tokenName = @"token";
    UIUserNotificationSettings *__block currentUserNotificationSettings = nil;

    beforeEach(^{
        UIApplication *application = [UIApplication nullMock];
        [UIApplication stub:@selector(sharedApplication) andReturn:application];
        currentUserNotificationSettings = [UIUserNotificationSettings nullMock];
        [application stub:@selector(currentUserNotificationSettings) andReturn:currentUserNotificationSettings];
    });

    context(@"Device token model", ^{

        context(@"Token name", ^{

            it(@"Should have correct token name", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeAlert)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(retrievedTokenModel.token) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:tokenName];
            });
        });

        context(@"Notifications should be enabled if any of their type is enabled", ^{

            it(@"Should have enabled true if badge notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeBadge)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(theValue(retrievedTokenModel.enabled)) shouldEventuallyBeforeTimingOutAfter(1.0)] beYes];
            });

            it(@"Should have enabled true if sound notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeSound)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(theValue(retrievedTokenModel.enabled)) shouldEventuallyBeforeTimingOutAfter(1.0)] beYes];
            });

            it(@"Should have enabled true if alert notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeAlert)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(theValue(retrievedTokenModel.enabled)) shouldEventuallyBeforeTimingOutAfter(1.0)] beYes];
            });

            it(@"Should have enabled false if notification are disabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(0)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(theValue(retrievedTokenModel.enabled)) shouldEventuallyBeforeTimingOutAfter(1.0)] beNo];
            });
        });

        context(@"Model notifications enabled should correspond to notifications permissions", ^{

            NSArray *(^subscribedNotifications)(BOOL, BOOL, BOOL) = ^NSArray *(BOOL badgeEnabled,
                                                                               BOOL soundEnabled,
                                                                               BOOL alertEnabled) {
                return @[
                    [[AMPSubscribedNotification alloc] initWithName:@"badge" enabled:badgeEnabled],
                    [[AMPSubscribedNotification alloc] initWithName:@"sound" enabled:soundEnabled],
                    [[AMPSubscribedNotification alloc] initWithName:@"alert" enabled:alertEnabled],
                ];
            };

            it(@"Should have badge enabled true if badge notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeBadge)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(retrievedTokenModel.notifications) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:subscribedNotifications(YES, NO, NO)];
            });

            it(@"Should have sound enabled true if sound notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeSound)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(retrievedTokenModel.notifications) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:subscribedNotifications(NO, YES, NO)];
            });

            it(@"Should have alert enabled true if alert notification are enabled", ^{
                [currentUserNotificationSettings stub:@selector(types) andReturn:theValue(UIUserNotificationTypeAlert)];
                AMPTokenEvent *__block retrievedTokenModel = nil;
                [AMPTokenEventModelProvider retrieveTokenEventWithToken:tokenName
                                                                  block:^(AMPTokenEvent *tokenModel) {
                                                                      retrievedTokenModel = tokenModel;
                }];
                [[expectFutureValue(retrievedTokenModel.notifications) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:subscribedNotifications(NO, NO, YES)];
            });

        });

    });

});

SPEC_END
