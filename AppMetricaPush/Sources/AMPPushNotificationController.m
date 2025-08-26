
#import "AMPPushNotificationController.h"

#import "AMPDeviceTokenParser.h"
#import "AMPPushNotificationPayload.h"
#import "AMPPushNotificationPayloadParser.h"
#import "AMPPushNotificationPayloadValidator.h"
#import "AMPApplicationStateProvider.h"
#import "AMPTargetURLHandler.h"
#import "AMPEventsController.h"
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPDispatchQueueWhenActiveStateExecutor.h"
#import "AMPSubscribedNotification.h"
#import "AMPTokenEventModelProvider.h"
#import "AMPUserNotificationCenterController.h"
#import "AMPPendingPushController.h"
#import "AMPPendingPush.h"
#import "AMPTrackingDeduplicationController.h"
#import "AMPLazyPushProvider.h"

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>
#import <AppMetricaPlatform/AppMetricaPlatform.h>

@interface AMPPushNotificationController () <AMPPendingPushControllerDelegate>

@property (nonatomic, strong, readonly) AMPDeviceTokenParser *tokenParser;

@property (nonatomic, strong, readonly) AMPPushNotificationPayloadParser *payloadParser;
@property (nonatomic, strong, readonly) AMPPushNotificationPayloadValidator *payloadValidator;
@property (nonatomic, strong, readonly) AMPApplicationStateProvider *applicationStateProvider;
@property (nonatomic, strong, readonly) AMPTargetURLHandler *targetURLHandler;

@property (nonatomic, strong, readonly) AMPEventsController *eventsController;
@property (nonatomic, strong, readonly) AMPLibraryAnalyticsTracker *libraryAnalyticsTracker;
@property (nonatomic, strong, readonly) AMPPendingPushController *pendingPushController;
@property (nonatomic, strong, readonly) AMPTrackingDeduplicationController *deduplicationController;

@property (nonatomic, strong, readonly) UNUserNotificationCenter *notificationCenter;

@end

@implementation AMPPushNotificationController

@synthesize pendingPushController = _pendingPushController;

- (instancetype)init
{
    AMPDispatchQueueWhenActiveStateExecutor *executor = [[AMPDispatchQueueWhenActiveStateExecutor alloc] init];
    AMPApplicationStateProvider *applicationStateProvider = [[AMPApplicationStateProvider alloc] init];
    
    return [self initWithTokenParser:[[AMPDeviceTokenParser alloc] init]
                       payloadParser:[[AMPPushNotificationPayloadParser alloc] init]
                    payloadValidator:[[AMPPushNotificationPayloadValidator alloc] init]
            applicationStateProvider:applicationStateProvider
                    targetURLHandler:[[AMPTargetURLHandler alloc] initWithExecutor:executor]
                    eventsController:[AMPEventsController sharedInstance]
             libraryAnalyticsTracker:[AMPLibraryAnalyticsTracker sharedInstance]
             deduplicationController:[[AMPTrackingDeduplicationController alloc] init]
                  notificationCenter:[UNUserNotificationCenter currentNotificationCenter]];
}

- (instancetype)initWithTokenParser:(AMPDeviceTokenParser *)tokenParser
                      payloadParser:(AMPPushNotificationPayloadParser *)payloadParser
                   payloadValidator:(AMPPushNotificationPayloadValidator *)payloadValidator
           applicationStateProvider:(AMPApplicationStateProvider*)applicationStateProvider
                   targetURLHandler:(AMPTargetURLHandler *)targetURLHandler
                   eventsController:(AMPEventsController *)eventsController
            libraryAnalyticsTracker:(AMPLibraryAnalyticsTracker *)libraryAnalyticsTracker
            deduplicationController:(AMPTrackingDeduplicationController *)deduplicationController
                 notificationCenter:(UNUserNotificationCenter *)notificationCenter
{
    self = [super init];
    if (self != nil) {
        _tokenParser = tokenParser;
        _payloadParser = payloadParser;
        _payloadValidator = payloadValidator;
        _applicationStateProvider = applicationStateProvider;
        _targetURLHandler = targetURLHandler;

        _eventsController = eventsController;
        _libraryAnalyticsTracker = libraryAnalyticsTracker;
        _deduplicationController = deduplicationController;
        _notificationCenter = notificationCenter;
    }
    return self;
}

- (AMPPendingPushController *)pendingPushController
{
    if (_pendingPushController == nil) {
        _pendingPushController = [AMPPendingPushController new];
        _pendingPushController.delegate = self;
    }
    return _pendingPushController;
}

- (void)setDeviceTokenFromData:(NSData *)data pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment
{
    NSString *token = [self.tokenParser deviceTokenFromData:data];
    
    [AMPTokenEventModelProvider retrieveTokenEventWithToken:token block:^(AMPTokenEvent *tokenModel){
        [self.eventsController reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
    }];
}

- (void)handleApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *pushNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushNotificationUserInfo != nil) {
        [self handlePushNotification:pushNotificationUserInfo applicationState:AMPApplicationStateBackground];
    }
}

- (void)handleSceneWillConnectToSessionWithOptions:(UISceneConnectionOptions *)connectionOptions
{
    NSDictionary *pushNotificationUserInfo = connectionOptions.notificationResponse.notification.request.content.userInfo;
    if (pushNotificationUserInfo != nil) {
        [self handlePushNotification:pushNotificationUserInfo applicationState:AMPApplicationStateBackground];
    }
}

- (void)handleDidReceiveNotificationRequestWithUserInfo:(NSDictionary *)userInfo
{
    AMPPushNotificationPayload *payload = [self parsedPayloadForUserInfo:userInfo];
    if ([self.payloadValidator isPayloadValidForTracking:payload]) {
        [self handleDidReceiveNotificationWithNotificationID:payload.notificationID];
    }
}

- (void)handleDidReceiveNotificationWithNotificationID:(NSString *)notificationID
{
    [self trackPushNotificationReceivedWithNotificationID:notificationID];
    [self.eventsController sendEventsBuffer];
}

- (void)handleNotificationContent:(UNNotificationContent *)content
                withResultHandler:(AMPPushProcessorCallback)resultHandler
{
    AMPPushNotificationPayload *payload = [self parsedPayloadForUserInfo:content.userInfo];
    [[AMPLazyPushProvider sharedInstance] processNotificationContent:content
                                                         withPayload:payload
                                                       resultHandler:resultHandler];
}

- (void)handlePushNotification:(NSDictionary *)notification
{
    [self handlePushNotification:notification applicationState:[self.applicationStateProvider currentApplicationState]];
}

- (void)handleUserNotificationCenterPush:(NSDictionary *)notification
{
    [self handlePushNotification:notification
                applicationState:self.applicationStateProvider.userNotificationCenterPushApplicationState];
}

- (void)handlePushNotification:(NSDictionary *)notification applicationState:(AMPApplicationState)applicationState
{
    AMPPushNotificationPayload *payload = [self parsedPayloadForUserInfo:notification];
    @synchronized (self.deduplicationController) {
        if ([self.deduplicationController shouldReportEventForNotification:payload] == NO) {
            return;
        }
        [self.deduplicationController markEventReportedForNotification:payload];
    }
    if ([self.payloadValidator isPayloadValidForTracking:payload]) {
        if (payload.silent) {
            [self trackPushNotificationWithPayload:payload actionType:kAMPEventsControllerActionTypeProcessed actionID:nil];
        }
        else {
            [self trackPushNotificationShownWithPayload:payload];
            [self trackPushNotificationWithNotificationID:payload.notificationID
                                               actionType:kAMPEventsControllerActionTypeOpen
                                                 actionID:nil
                                                      uri:payload.targetURL];
        }
        
        [self removeNotificationsIfNeeded:payload];
    }
    if ([self.payloadValidator isPayloadValidForURLOpening:payload]) {
        [self openPushNotificationTargetURL:payload.targetURL applicationState:applicationState];
    }
}

- (void)handlePushNotificationDismissWithUserInfo:(NSDictionary *)userInfo
{
    AMPPushNotificationPayload *payload = [self parsedPayloadForUserInfo:userInfo];
    if ([self.payloadValidator isPayloadValidForTracking:payload]) {
        [self trackPushNotificationShownWithPayload:payload];
        [self trackPushNotificationWithPayload:payload
                                    actionType:kAMPEventsControllerActionTypeDismiss
                                      actionID:nil];
    }
}

- (AMPPushNotificationPayload *)parsedPayloadForUserInfo:(NSDictionary *)userInfo
{
    AMPPushNotificationPayload *payload = nil;
    if (userInfo == nil) {
        [self.libraryAnalyticsTracker reportInvalidNotification:nil withReason:@"is_nil"];
    }
    else if ([userInfo isKindOfClass:[NSDictionary class]] == NO) {
        [self.libraryAnalyticsTracker reportInvalidNotification:nil withReason:@"is_not_dictionary"];
    }
    else {
        payload = [self.payloadParser pushNotificationPayloadFromDictionary:userInfo];
        if (payload == nil) {
            [self.libraryAnalyticsTracker reportInvalidNotification:userInfo withReason:@"is_not_valid"];
        }
    }
    return payload;
}

- (void)trackPushNotificationWithPayload:(AMPPushNotificationPayload *)payload
                              actionType:(NSString *)actionType
                                actionID:(NSString *)actionID
{
    [self trackPushNotificationWithNotificationID:payload.notificationID
                                       actionType:actionType
                                         actionID:actionID
                                              uri:nil];
}

- (void)trackPushNotificationWithNotificationID:(NSString *)notificationID
                                     actionType:(NSString *)actionType
                                       actionID:(NSString *)actionID
                                            uri:(NSString *)uri
{
    [self.eventsController reportPushNotificationWithNotificationID:notificationID
                                                         actionType:actionType
                                                           actionID:actionID
                                                                uri:uri
                                                          onFailure:nil];
}

- (void)trackPushNotificationShownWithPayload:(AMPPushNotificationPayload *)payload
{
    [self trackPushNotificationWithNotificationID:payload.notificationID
                                       actionType:kAMPEventsControllerActionTypeShown
                                         actionID:nil
                                              uri:nil];
}

- (void)trackPushNotificationReceivedWithNotificationID:(NSString *)notificationID
{
    [self trackPushNotificationWithNotificationID:notificationID
                                       actionType:kAMPEventsControllerActionTypeReceive
                                         actionID:nil
                                              uri:nil];
    [self trackPushNotificationWithNotificationID:notificationID
                                       actionType:kAMPEventsControllerActionTypeShown
                                         actionID:nil
                                              uri:nil];
}

- (void)openPushNotificationTargetURL:(NSString *)targetURL
                     applicationState:(AMPApplicationState)applicationState
{
    [self.targetURLHandler handleURL:targetURL applicationState:applicationState];
}

- (NSString *)userDataForNotification:(NSDictionary *)notification
{
    NSString *userData = nil;
    AMPPushNotificationPayload *payload = [self.payloadParser pushNotificationPayloadFromDictionary:notification];
    if ([self.payloadValidator isPayloadValidForUserDataProviding:payload]) {
        userData = payload.userData;
    }
    return userData;
}

- (BOOL)isNotificationRelatedToSDK:(NSDictionary *)notification
{
    AMPPushNotificationPayload *payload = [self.payloadParser pushNotificationPayloadFromDictionary:notification];
    return [self.payloadValidator isPayloadGenerallyValid:payload];
}

- (void)setURLOpenDispatchQueue:(dispatch_queue_t)queue
{
    AMPDispatchQueueWhenActiveStateExecutor *executor =
            [[AMPDispatchQueueWhenActiveStateExecutor alloc] initWithQueue:queue];
    @synchronized (self) {
        self.targetURLHandler.executor = executor;
    }
}

- (void)setExtensionAppGroup:(NSString *)appGroup
{
    // no sense if application or extension are callee, both cases cause to create events and send them
    [self.pendingPushController updateExtensionAppGroup:appGroup];
    [self.pendingPushController notifyAboutPendingPushes];
}

- (void)removeNotificationsIfNeeded:(AMPPushNotificationPayload *)payload
{
    if (payload.silent == NO) {
        return;
    }
    if (payload.delCollapseIDs.count == 0) {
        return;
    }
    
    [self.notificationCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        NSMutableArray<NSString *> *delIds = [NSMutableArray array];
        for (UNNotification *notification in notifications) {
            if ([payload.delCollapseIDs containsObject:notification.request.identifier]) {
                [delIds addObject:notification.request.identifier];
                [self trackPushNotificationRemovedIfNeeded:notification];
            }
        }
        [self.notificationCenter removeDeliveredNotificationsWithIdentifiers:delIds];
    }];
}

- (void)trackPushNotificationRemovedIfNeeded:(UNNotification *)notification
{
    AMPPushNotificationPayload *delivered = [self parsedPayloadForUserInfo:notification.request.content.userInfo];
    if (delivered.notificationID != nil) {
        [self trackPushNotificationWithPayload:delivered
                                    actionType:kAMPEventsControllerActionTypeRemoved
                                      actionID:nil];
    }
}

+ (instancetype)sharedInstance
{
    static AMPPushNotificationController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[AMPPushNotificationController alloc] init];
    });
    return controller;
}

#pragma mark - AMPPendingPushControllerDelegate

- (void)pendingPushController:(AMPPendingPushController *)controller didNotifyPendingPush:(AMPPendingPush *)push
{
    [self trackPushNotificationReceivedWithNotificationID:push.notificationID];
}

@end
