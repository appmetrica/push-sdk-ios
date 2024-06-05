
#import "AMPAppMetricaPush.h"

#import "AMPPushNotificationController.h"
#import "AMPUserNotificationCenterController.h"
#import "AMPUserNotificationCenterHandler.h"
#import "AMPPushController.h"
#import "AMPAttachmentsController.h"

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>


NSErrorDomain const kAMPAppMetricaPushErrorDomain = @"io.appmetrica.push";

@implementation AMPAppMetricaPush

+ (id<AMPUserNotificationCenterDelegate>)userNotificationCenterDelegate
{
    return [AMPUserNotificationCenterController sharedInstance];
}

+ (id<AMPUserNotificationCenterHandling>)userNotificationCenterHandler
{
    return [AMPUserNotificationCenterHandler sharedInstance];
}

+ (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                    withResultHandler:(AMPPushControllerCallback)resultHandler
{
    return [[AMPPushController sharedInstance] processNotificationContent:request.content
                                                        withResultHandler:resultHandler];
}

+ (void)setDeviceTokenFromData:(NSData *)data
{
    [[self class] setDeviceTokenFromData:data pushEnvironment:AMPAppMetricaPushEnvironmentProduction];
}

+ (void)setDeviceTokenFromData:(NSData *)data pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment
{
    [[AMPPushNotificationController sharedInstance] setDeviceTokenFromData:data pushEnvironment:pushEnvironment];
}

+ (void)handleApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AMPPushNotificationController sharedInstance] handleApplicationDidFinishLaunchingWithOptions:launchOptions];
}

+ (void)handleSceneWillConnectToSessionWithOptions:(UISceneConnectionOptions *)connectionOptions
{
    [[AMPPushNotificationController sharedInstance] handleSceneWillConnectToSessionWithOptions:connectionOptions];
}

+ (void)handleDidReceiveNotificationRequest:(UNNotificationRequest *)request
{
    NSDictionary *userInfo = request.content.userInfo;
    [[AMPPushNotificationController sharedInstance] handleDidReceiveNotificationRequestWithUserInfo:userInfo];
}

+ (void)downloadAttachmentsForNotificationRequest:(UNNotificationRequest *)request
                                         callback:(AMPAttachmentsDownloadCallback)callback
{
    [[AMPAttachmentsController sharedInstance] downloadAttachmentsForUserInfo:request.content.userInfo
                                                                     callback:callback];
}

+ (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    [[AMPPushNotificationController sharedInstance] handlePushNotification:userInfo];
}

+ (NSString *)userDataForNotification:(NSDictionary *)userInfo
{
    return [[AMPPushNotificationController sharedInstance] userDataForNotification:userInfo];
}

+ (BOOL)isNotificationRelatedToSDK:(NSDictionary *)userInfo
{
    return [[AMPPushNotificationController sharedInstance] isNotificationRelatedToSDK:userInfo];
}

+ (void)setURLOpenDispatchQueue:(dispatch_queue_t)queue
{
    [[AMPPushNotificationController sharedInstance] setURLOpenDispatchQueue:queue];
}

+ (void)setExtensionAppGroup:(NSString *)appGroup
{
    [[AMPPushNotificationController sharedInstance] setExtensionAppGroup:appGroup];
}

#pragma mark - Extended

+ (void)disableEventsCaching
{
    [[AMPPushNotificationController sharedInstance] disableEventsCaching];
}

@end
