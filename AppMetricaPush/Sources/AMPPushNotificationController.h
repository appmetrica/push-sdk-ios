
#import <Foundation/Foundation.h>
#import <AppMetricaPush/AppMetricaPush.h>
#import "AMPPushProcessor.h"

@class AMPDeviceTokenParser;
@class AMPPushNotificationPayloadParser;
@class AMPPushNotificationPayloadValidator;
@class AMPApplicationStateProvider;
@class AMPTargetURLHandler;
@class AMPEventsController;
@class AMPLibraryAnalyticsTracker;
@class AMPPendingPushController;
@class UNNotificationRequest;
@class AMPPendingPushController;
@class AMPTrackingDeduplicationController;
@class UNNotificationContent;
@class UISceneConnectionOptions;

@interface AMPPushNotificationController : NSObject

- (instancetype)initWithTokenParser:(AMPDeviceTokenParser *)tokenParser
                      payloadParser:(AMPPushNotificationPayloadParser *)payloadParser
                   payloadValidator:(AMPPushNotificationPayloadValidator *)payloadValidator
           applicationStateProvider:(AMPApplicationStateProvider *)applicationStateProvider
                   targetURLHandler:(AMPTargetURLHandler *)targetURLHandler
                   eventsController:(AMPEventsController *)eventsController
            libraryAnalyticsTracker:(AMPLibraryAnalyticsTracker *)libraryAnalyticsTracker
              pendingPushController:(AMPPendingPushController *)pendingPushController
            deduplicationController:(AMPTrackingDeduplicationController *)deduplicationController;

- (void)setDeviceTokenFromData:(NSData *)data pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment;
- (void)handleApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)handleSceneWillConnectToSessionWithOptions:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0));
- (void)handlePushNotification:(NSDictionary *)notification;
- (void)handleUserNotificationCenterPush:(NSDictionary *)notification;
- (void)handleDidReceiveNotificationRequestWithUserInfo:(NSDictionary *)userInfo;
- (void)handleDidReceiveNotificationWithNotificationID:(NSString *)notificationID;
- (void)handleNotificationContent:(UNNotificationContent *)content
                withResultHandler:(AMPPushProcessorCallback)resultHandler;

- (NSString *)userDataForNotification:(NSDictionary *)notification;
- (BOOL)isNotificationRelatedToSDK:(NSDictionary *)notification;

- (void)setURLOpenDispatchQueue:(dispatch_queue_t)queue;
- (void)handlePushNotificationDismissWithUserInfo:(NSDictionary *)userInfo;
- (void)setExtensionAppGroup:(NSString *)appGroup;

- (void)disableEventsCaching;

+ (instancetype)sharedInstance;

@end
