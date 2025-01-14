
#import <Kiwi/Kiwi.h>

#import "AMPPushNotificationController.h"
#import "AMPUserNotificationCenterController.h"

@interface AMPAppMetricaPush (Test)

+ (void)setURLOpenDispatchQueue:(dispatch_queue_t)queue;

@end

SPEC_BEGIN(AMPPushMetricaPushTests)

describe(@"AMPPushMetricaPush", ^{

    let(controller, ^id{
        return [AMPPushNotificationController nullMock];
    });

    beforeEach(^{
        [AMPPushNotificationController stub:@selector(sharedInstance) andReturn:controller];
    });

    it(@"Shold return shared instance of user notification center controller", ^{
        AMPUserNotificationCenterController *expectedInstance = [AMPUserNotificationCenterController nullMock];
        [AMPUserNotificationCenterController stub:@selector(sharedInstance) andReturn:expectedInstance];
        id instance = [AMPAppMetricaPush userNotificationCenterDelegate];
        [[instance should] equal:expectedInstance];
    });

    it(@"Should call notifications controller on device token setting without environment", ^{
        NSData *tokenData = [NSData nullMock];
        [[controller should] receive:@selector(setDeviceTokenFromData:pushEnvironment:)
                       withArguments:tokenData, theValue(AMPAppMetricaPushEnvironmentProduction)];
        [AMPAppMetricaPush setDeviceTokenFromData:tokenData];
    });

    it(@"Should call notifications controller on device token setting with production environment", ^{
        NSData *tokenData = [NSData nullMock];
        [[controller should] receive:@selector(setDeviceTokenFromData:pushEnvironment:)
                       withArguments:tokenData, theValue(AMPAppMetricaPushEnvironmentProduction)];
        [AMPAppMetricaPush setDeviceTokenFromData:tokenData
                                     pushEnvironment:AMPAppMetricaPushEnvironmentProduction];
    });

    it(@"Should call notifications controller on device token setting without environment", ^{
        NSData *tokenData = [NSData nullMock];
        [[controller should] receive:@selector(setDeviceTokenFromData:pushEnvironment:)
                       withArguments:tokenData, theValue(AMPAppMetricaPushEnvironmentDevelopment)];
        [AMPAppMetricaPush setDeviceTokenFromData:tokenData
                                     pushEnvironment:AMPAppMetricaPushEnvironmentDevelopment];
    });

    it(@"Should call notifications controller on notification handling", ^{
        NSDictionary *info = [NSDictionary nullMock];
        [[controller should] receive:@selector(handlePushNotification:) withArguments:info];
        [AMPAppMetricaPush handleRemoteNotification:info];
    });

    it(@"Should call notifications controller on user data getting", ^{
        NSDictionary *info = [NSDictionary nullMock];
        [[controller should] receive:@selector(userDataForNotification:) withArguments:info];
        [AMPAppMetricaPush userDataForNotification:info];
    });

    it(@"Should call notifications controller on check if notification is related to SDK", ^{
        NSDictionary *info = [NSDictionary nullMock];
        [[controller should] receive:@selector(isNotificationRelatedToSDK:) withArguments:info];
        [AMPAppMetricaPush isNotificationRelatedToSDK:info];
    });

    it(@"Should call notifications controller on URL open queue setting", ^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        [[controller should] receive:@selector(setURLOpenDispatchQueue:) withArguments:queue];
        [AMPAppMetricaPush setURLOpenDispatchQueue:queue];
    });
    
    it(@"Should call notifications controller on setting extension app group", ^{
        NSString *appGroup = @"extensionAppGroup";
        [[controller should] receive:@selector(setExtensionAppGroup:) withArguments:appGroup];
        [AMPAppMetricaPush setExtensionAppGroup:appGroup];
    });

    if (@available(iOS 13.0, *)) {
        it(@"Should call handle scene connection options", ^{
            UISceneConnectionOptions *connectionOptions = [UISceneConnectionOptions nullMock];
            [[controller should] receive:@selector(handleSceneWillConnectToSessionWithOptions:)
                           withArguments:connectionOptions];
            [AMPAppMetricaPush handleSceneWillConnectToSessionWithOptions:connectionOptions];
        });
    }
});

SPEC_END
