
#import <Kiwi/Kiwi.h>
#import <UserNotifications/UserNotifications.h>

#import "AMPUserNotificationCenterHandler.h"
#import "AMPPushNotificationController.h"

SPEC_BEGIN(AMPUserNotificationCenterHandlerTests)

describe(@"AMPUserNotificationCenterHandler", ^{

    AMPPushNotificationController *__block controller = nil;
    AMPUserNotificationCenterHandler *__block handler = nil;

    beforeEach(^{
        controller = [AMPPushNotificationController nullMock];
        handler = [[AMPUserNotificationCenterHandler alloc] initWithPushNotificationController:controller];
    });

    context(@"Did receive", ^{
        NSDictionary *userInfo = @{ @"foo": @"bar" };
        UNNotificationResponse *__block response = nil;

        beforeEach(^{
            response = [UNNotificationResponse nullMock];
            UNNotification *notification = [UNNotification nullMock];
            UNNotificationRequest *request = [UNNotificationRequest nullMock];
            UNNotificationContent *content = [UNNotificationContent nullMock];
            [content stub:@selector(userInfo) andReturn:userInfo];
            [request stub:@selector(content) andReturn:content];
            [notification stub:@selector(request) andReturn:request];
            [response stub:@selector(notification) andReturn:notification];
        });

        context(@"Push open", ^{
            it(@"Should report notification user info", ^{
                [[controller should] receive:@selector(handleUserNotificationCenterPush:) withArguments:userInfo];
                [handler userNotificationCenterDidReceiveNotificationResponse:response];
            });
            it(@"Should not report dismiss", ^{
                [[controller shouldNot] receive:@selector(handlePushNotificationDismissWithUserInfo:)];
                [handler userNotificationCenterDidReceiveNotificationResponse:response];
            });
        });
        context(@"Dismiss", ^{
            beforeEach(^{
                [response stub:@selector(actionIdentifier) andReturn:UNNotificationDismissActionIdentifier];
            });
            it(@"Should not report notification user info", ^{
                [[controller shouldNot] receive:@selector(handleUserNotificationCenterPush:)];
                [handler userNotificationCenterDidReceiveNotificationResponse:response];
            });
            it(@"Should report dismiss", ^{
                [[controller should] receive:@selector(handlePushNotificationDismissWithUserInfo:) withArguments:userInfo];
                [handler userNotificationCenterDidReceiveNotificationResponse:response];
            });
        });
    });

});

SPEC_END

