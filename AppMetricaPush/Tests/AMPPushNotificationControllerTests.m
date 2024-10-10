
#import <Kiwi/Kiwi.h>
#import <UserNotifications/UserNotifications.h>

#import "AMPPushNotificationController.h"
#import "AMPDeviceTokenParser.h"
#import "AMPPushNotificationPayloadParser.h"
#import "AMPPushNotificationPayloadValidator.h"
#import "AMPEventsController.h"
#import "AMPApplicationStateProvider.h"
#import "AMPTargetURLHandler.h"
#import "AMPPushNotificationPayload.h"
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPDispatchQueueWhenActiveStateExecutor.h"
#import "AMPTokenEvent.h"
#import "AMPTokenEventModelProvider.h"
#import "AMPPendingPushController.h"
#import "AMPPendingPush.h"
#import "AMPTrackingDeduplicationController.h"
#import "AMPPendingNotificationStrategy.h"

@interface AMPPushNotificationController () <AMPPendingPushControllerDelegate, AMPApplicationStateProviderDelegate>

- (void)handlePushNotification:(NSDictionary *)notification applicationState:(AMPApplicationState)applicationState;

@end

SPEC_BEGIN(AMPPushNotificationControllerTests)

describe(@"AMPPushNotificationController", ^{

    AMPPushNotificationController *__block notificationsController = nil;
    AMPDeviceTokenParser *__block tokenParser = nil;
    AMPPushNotificationPayloadParser *__block payloadParser = nil;
    AMPPushNotificationPayloadValidator *__block payloadValidator = nil;
    AMPApplicationStateProvider *__block applicationStateProvider = nil;
    AMPTargetURLHandler *__block targetURLHandler = nil;
    AMPPendingPushController *__block pendingPushController = nil;
    AMPTrackingDeduplicationController *__block deduplicationController = nil;
    AMPPendingNotificationStrategy *__block notifyStrategy = nil;
    UNUserNotificationCenter *__block notificationCenter = nil;

    AMPEventsController *__block eventsController = nil;
    AMPLibraryAnalyticsTracker *__block libraryTracker = nil;

    beforeEach(^{
        tokenParser = [AMPDeviceTokenParser nullMock];
        payloadParser = [AMPPushNotificationPayloadParser nullMock];
        payloadValidator = [AMPPushNotificationPayloadValidator nullMock];
        applicationStateProvider = [AMPApplicationStateProvider nullMock];
        [applicationStateProvider stub:@selector(currentApplicationState) andReturn:@0];
        targetURLHandler = [AMPTargetURLHandler nullMock];
        libraryTracker = [AMPLibraryAnalyticsTracker nullMock];
        eventsController = [AMPEventsController nullMock];
        pendingPushController = [AMPPendingPushController nullMock];
        deduplicationController = [AMPTrackingDeduplicationController nullMock];
        notifyStrategy = [AMPPendingNotificationStrategy nullMock];
        [deduplicationController stub:@selector(shouldReportEventForNotification:)
                            andReturn:theValue(YES)];
        [notifyStrategy stub:@selector(handlePushNotification)];
        notificationCenter = [UNUserNotificationCenter nullMock];

        notificationsController = [[AMPPushNotificationController alloc] initWithTokenParser:tokenParser
                                                                               payloadParser:payloadParser
                                                                            payloadValidator:payloadValidator
                                                                    applicationStateProvider:applicationStateProvider
                                                                            targetURLHandler:targetURLHandler
                                                                            eventsController:eventsController
                                                                     libraryAnalyticsTracker:libraryTracker
                                                                       pendingPushController:pendingPushController
                                                                     deduplicationController:deduplicationController
                                                                       pendingNotifyStrategy:notifyStrategy
                                                                          notificationCenter:notificationCenter];
    });

    context(@"Device Token", ^{

        NSString *const token = @"token";

        it(@"Should parse device token data", ^{
            NSData *tokenData = [NSData nullMock];
            [[tokenParser should] receive:@selector(deviceTokenFromData:) withArguments:tokenData];
            [notificationsController setDeviceTokenFromData:tokenData
                                            pushEnvironment:AMPAppMetricaPushEnvironmentProduction];
        });

        it(@"Should send parsed token with development push environment", ^{
            AMPTokenEvent *tokenModel = [[AMPTokenEvent alloc] initWithToken:token enabled:YES notifications:nil];
            [AMPTokenEventModelProvider stub:@selector(retrieveTokenEventWithToken:block:) withBlock:^id(NSArray *params) {
                void(^block)(AMPTokenEvent *tokenModel) = params[1];
                block(tokenModel);
                return nil;
            }];
            [[eventsController should] receive:@selector(reportDeviceTokenWithModel:pushEnvironment:onFailure:)
                                 withArguments:tokenModel, theValue(AMPAppMetricaPushEnvironmentDevelopment), kw_any()];
            [notificationsController setDeviceTokenFromData:[NSData nullMock]
                                            pushEnvironment:AMPAppMetricaPushEnvironmentDevelopment];
        });

    });

    context(@"Notification", ^{

        it(@"Should not report nil info", ^{
            [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
            [notificationsController handlePushNotification:nil];
        });

        it(@"Should not report non-dictionary info", ^{
            [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
            id nonDictionary = @"string";
            [notificationsController handlePushNotification:nonDictionary];
        });

        it(@"Should parse payload", ^{
            [[payloadParser should] receive:@selector(pushNotificationPayloadFromDictionary:)];
            [notificationsController handlePushNotification:@{}];
        });

        it(@"Should not report invalid info", ^{
            [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(NO)];
            [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
            [notificationsController handlePushNotification:@{}];
        });
        
        context(@"Del collapse ids", ^{
            NSArray *__block delIds = nil;
            UNNotification *__block notification = nil;
            UNNotificationRequest *__block request = nil;
            NSString *const identifier = @"collapse-id-2";
            NSString *const notificationID = @"notificationID";
            AMPPushNotificationPayload *__block payload = nil;
            UNNotificationContent *__block content = nil;
            beforeEach(^{
                delIds = @[@"collapse-id-1",
                           identifier];
                
                payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:notificationID
                                                                           targetURL:@""
                                                                            userData:@""
                                                                         attachments:@[]
                                                                              silent:YES
                                                                      delCollapseIDs:delIds
                                                                                lazy:nil];
                [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:payload];
                [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(YES)];
                
                content = [UNNotificationContent nullMock];
                [content stub:@selector(userInfo) andReturn:@{
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"del-collapse-ids" : delIds
                    }
                }];
                
                request = [UNNotificationRequest nullMock];
                [request stub:@selector(identifier) andReturn:identifier];
                [request stub:@selector(content) andReturn:content];
                
                notification = [UNNotification nullMock];
                [notification stub:@selector(request) andReturn:request];
                
                [notificationCenter stub:@selector(getDeliveredNotificationsWithCompletionHandler:)
                               withBlock:^id(NSArray *params) {
                    void (^completionHandler)(NSArray<UNNotification *> *) = params[0];
                    completionHandler(@[notification]);
                    return nil;
                }];
            });
            it(@"Should not remove notifications without del collapse ids", ^{
                [payload stub:@selector(delCollapseIDs) andReturn:@[]];
                
                [[notificationCenter shouldNot] receive:@selector(getDeliveredNotificationsWithCompletionHandler:)];
                [[notificationCenter shouldNot] receive:@selector(removeDeliveredNotificationsWithIdentifiers:)];
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:
                                                                actionType:
                                                                actionID:
                                                                onFailure:)
                                        withArguments:kw_any(), kAMPEventsControllerActionTypeRemoved, kw_any(), kw_any()];
                
                [notificationsController handlePushNotification:@{}];
            });
            it(@"Should remove notification with del collapse ids", ^{
                [[notificationCenter should] receive:@selector(removeDeliveredNotificationsWithIdentifiers:)
                                       withArguments:@[identifier]];
                
                [notificationsController handlePushNotification:@{}];
            });
            
            it(@"Should not remove notification if the push is not silent", ^{
                [payload stub:@selector(silent) andReturn:theValue(NO)];
                
                [[notificationCenter shouldNot] receive:@selector(removeDeliveredNotificationsWithIdentifiers:)];
                
                [notificationsController handlePushNotification:@{}];
            });
            
            it(@"Should track removal notification", ^{
                [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:
                                                             actionType:
                                                             actionID:
                                                             onFailure:)
                                     withArguments:notificationID, kAMPEventsControllerActionTypeRemoved, kw_any(), kw_any()];
                
                [notificationsController handlePushNotification:@{}];
            });
            
            it(@"Should not track removal notification if unable to parse the delivered notification", ^{
                [content stub:@selector(userInfo) andReturn:nil];
                
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:
                                                                actionType:
                                                                actionID:
                                                                onFailure:)
                                        withArguments:kw_any(), kAMPEventsControllerActionTypeRemoved, kw_any(), kw_any()];
                
                [notificationsController handlePushNotification:@{}];
            });
        });

        context(@"Library analytics reporting", ^{

            it(@"Should report about nil info", ^{
                [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                   withArguments:nil, @"is_nil"];
                [notificationsController handlePushNotification:nil];
            });

            it(@"Should report about non-dictionary info", ^{
                [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                   withArguments:nil, @"is_not_dictionary"];
                id nonDictionary = @"string";
                [notificationsController handlePushNotification:nonDictionary];
            });

            it(@"Should report about invalid info", ^{
                NSDictionary *userInfo = @{ @"foo": @"bar" };
                [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                   withArguments:userInfo, @"is_not_valid"];
                [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:nil];
                [notificationsController handlePushNotification:userInfo];
            });

        });

        context(@"Notification content", ^{

            AMPPushNotificationPayload *__block parsedPayload = nil;
            NSMutableArray *__block reportedEventParameters = nil;

            beforeEach(^{
                [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(YES)];
                parsedPayload = [AMPPushNotificationPayload nullMock];
                [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:parsedPayload];

                reportedEventParameters = [NSMutableArray array];
                [eventsController stub:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                             withBlock:^id(NSArray *params) {
                                 [reportedEventParameters addObject:[params copy]];
                                 return nil;
                             }];
            });

            it(@"Should check for duplication", ^{
                [[deduplicationController should] receive:@selector(shouldReportEventForNotification:)
                                            withArguments:parsedPayload];
                [notificationsController handlePushNotification:@{}];
            });

            it(@"Should not report duplicated event", ^{
                [deduplicationController stub:@selector(shouldReportEventForNotification:) andReturn:theValue(NO)];
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                [notificationsController handlePushNotification:@{}];
            });

            it(@"Should mark event reported in deduplicator", ^{
                [[deduplicationController should] receive:@selector(markEventReportedForNotification:)
                                            withArguments:parsedPayload];
                [notificationsController handlePushNotification:@{}];
            });

            it(@"Should handle notification content on handleApplicationDidFinishLaunchingWithOptions", ^{
                NSDictionary *payload = @{ @"aps" : @"test" };
                NSDictionary *userInfo = @{UIApplicationLaunchOptionsRemoteNotificationKey: payload};
                [[notificationsController should] receive:@selector(handlePushNotification:applicationState:)
                withArguments:payload, kw_any()];

                [notificationsController handleApplicationDidFinishLaunchingWithOptions:userInfo];
            });

            if (@available(iOS 13.0, *)) {
                it(@"Should handle notification content on handleSceneWillConnectToSessionWithOptions", ^{
                    UISceneConnectionOptions *connectionOptions = [UISceneConnectionOptions nullMock];
                    UNNotificationResponse *response = [UNNotificationResponse nullMock];
                    UNNotification *notification = [UNNotification nullMock];
                    UNNotificationRequest *request = [UNNotificationRequest nullMock];
                    UNNotificationContent *content = [UNNotificationContent nullMock];
                    NSDictionary *userInfo = @{};
                    [content stub:@selector(userInfo) andReturn:userInfo];
                    [request stub:@selector(content) andReturn:content];
                    [notification stub:@selector(request) andReturn:request];
                    [response stub:@selector(notification) andReturn:notification];
                    [connectionOptions stub:@selector(notificationResponse) andReturn:response];

                    [[notificationsController should] receive:@selector(handlePushNotification:applicationState:)
                                                withArguments:userInfo, kw_any()];

                    [notificationsController handleSceneWillConnectToSessionWithOptions:connectionOptions];
                });
            }

            context(@"Shown event", ^{
                it(@"Should report actual notification id", ^{
                    NSString *notificationID = @"ID";
                    [parsedPayload stub:@selector(notificationID) andReturn:notificationID];
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[0][0] should] equal:notificationID];
                });

                it(@"Should report notification with shown action", ^{
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[0][1] should] equal:@"shown"];
                });

                it(@"Should not report notification with shown action for silent push", ^{
                    [parsedPayload stub:@selector(silent) andReturn:theValue(YES)];
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[0][1] shouldNot] equal:@"shown"];
                });

                it(@"Should report notification without action id", ^{
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[0][2] should] equal:[NSNull null]];
                });
            });

            context(@"Open/processed event", ^{
                it(@"Should report actual notification id", ^{
                    NSString *notificationID = @"ID";
                    [parsedPayload stub:@selector(notificationID) andReturn:notificationID];
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[1][0] should] equal:notificationID];
                });

                it(@"Should report notification with open action", ^{
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[1][1] should] equal:@"open"];
                });

                it(@"Should report notification with processed action for silent push", ^{
                    [parsedPayload stub:@selector(silent) andReturn:theValue(YES)];
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[0][1] should] equal:@"processed"];
                });

                it(@"Should report notification without action id", ^{
                    [notificationsController handlePushNotification:@{}];
                    [[reportedEventParameters[1][2] should] equal:[NSNull null]];
                });
            });
        });

        context(@"Dismiss", ^{

            it(@"Should not report nil info", ^{
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                [notificationsController handlePushNotificationDismissWithUserInfo:nil];
            });

            it(@"Should not report non-dictionary info", ^{
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                id nonDictionary = @"string";
                [notificationsController handlePushNotificationDismissWithUserInfo:nonDictionary];
            });

            it(@"Should parse payload", ^{
                [[payloadParser should] receive:@selector(pushNotificationPayloadFromDictionary:)];
                [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
            });

            it(@"Should not report invalid info", ^{
                [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(NO)];
                [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
            });

            context(@"Library analytics reporting", ^{

                it(@"Should report about nil info", ^{
                    [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                       withArguments:nil, @"is_nil"];
                    [notificationsController handlePushNotificationDismissWithUserInfo:nil];
                });

                it(@"Should report about non-dictionary info", ^{
                    [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                       withArguments:nil, @"is_not_dictionary"];
                    id nonDictionary = @"string";
                    [notificationsController handlePushNotificationDismissWithUserInfo:nonDictionary];
                });

                it(@"Should report about invalid info", ^{
                    NSDictionary *userInfo = @{ @"foo": @"bar" };
                    [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                       withArguments:userInfo, @"is_not_valid"];
                    [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:nil];
                    [notificationsController handlePushNotificationDismissWithUserInfo:userInfo];
                });

            });

            context(@"Notification content", ^{

                AMPPushNotificationPayload *__block parsedPayload = nil;
                NSMutableArray *__block reportedEventParameters = nil;

                beforeEach(^{
                    [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(YES)];
                    parsedPayload = [AMPPushNotificationPayload nullMock];
                    [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:parsedPayload];

                    reportedEventParameters = [NSMutableArray array];
                    [eventsController stub:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                 withBlock:^id(NSArray *params) {
                                     [reportedEventParameters addObject:[params copy]];
                                     return nil;
                                 }];
                });

                context(@"Shown event", ^{
                    it(@"Should report actual notification id", ^{
                        NSString *notificationID = @"ID";
                        [parsedPayload stub:@selector(notificationID) andReturn:notificationID];
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[0][0] should] equal:notificationID];
                    });

                    it(@"Should report notification with shown action", ^{
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[0][1] should] equal:@"shown"];
                    });

                    it(@"Should report notification without action id", ^{
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[0][2] should] equal:[NSNull null]];
                    });
                });

                context(@"Open/processed event", ^{
                    it(@"Should report actual notification id", ^{
                        NSString *notificationID = @"ID";
                        [parsedPayload stub:@selector(notificationID) andReturn:notificationID];
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[1][0] should] equal:notificationID];
                    });

                    it(@"Should report notification with open action", ^{
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[1][1] should] equal:@"dismiss"];
                    });

                    it(@"Should report notification without action id", ^{
                        [notificationsController handlePushNotificationDismissWithUserInfo:@{}];
                        [[reportedEventParameters[1][2] should] equal:[NSNull null]];
                    });
                });
            });
        });

        context(@"Target URL handling", ^{

            NSString *const targetURL = @"https://ya.ru";
            AMPPushNotificationPayload *__block payload = nil;

            beforeEach(^{
                payload = [AMPPushNotificationPayload nullMock];
                [payload stub:@selector(targetURL) andReturn:targetURL];
                [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:payload];
            });

            it(@"Should not handle URL for invalid payload", ^{
                [payloadValidator stub:@selector(isPayloadValidForURLOpening:) andReturn:theValue(NO)];
                [[targetURLHandler shouldNot] receive:@selector(handleURL:applicationState:)];
                [notificationsController handlePushNotification:@{}];
            });

            context(@"Valid payload", ^{

                beforeEach(^{
                    [payloadValidator stub:@selector(isPayloadValidForURLOpening:) andReturn:theValue(YES)];
                });

                it(@"Should not open duplicated event URL", ^{
                    [deduplicationController stub:@selector(shouldReportEventForNotification:) andReturn:theValue(NO)];
                    [[targetURLHandler shouldNot] receive:@selector(handleURL:applicationState:)];
                    [notificationsController handlePushNotification:@{}];
                });

                it(@"Shoud pass AMPApplicationStateForeground from state provider", ^{
                    [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateForeground)];
                    [[targetURLHandler should] receive:@selector(handleURL:applicationState:) withArguments:kw_any(), theValue(AMPApplicationStateForeground)];
                    [notificationsController handlePushNotification:@{}];
                });

                it(@"Shoud pass AMPApplicationStateBackground from state provider", ^{
                    [applicationStateProvider stub:@selector(currentApplicationState) andReturn:theValue(AMPApplicationStateBackground)];
                    [[targetURLHandler should] receive:@selector(handleURL:applicationState:) withArguments:kw_any(), theValue(AMPApplicationStateBackground)];
                    [notificationsController handlePushNotification:@{}];
                });

                it(@"Shoud pass userNotificationCenterPushApplicationState value from state provider for UNC push", ^{
                    [applicationStateProvider stub:@selector(userNotificationCenterPushApplicationState)
                                         andReturn:theValue(AMPApplicationStateBackground)];
                    [[targetURLHandler should] receive:@selector(handleURL:applicationState:) withArguments:kw_any(), theValue(AMPApplicationStateBackground)];
                    [notificationsController handleUserNotificationCenterPush:@{}];
                });

                it(@"Shoud pass URL value from payload", ^{
                    [[targetURLHandler should] receive:@selector(handleURL:applicationState:) withArguments:targetURL, kw_any()];
                    [notificationsController handlePushNotification:@{}];
                });

            });

        });

        context(@"Handle notification from extension", ^{
            NSString *notificationID = @"NOTIFICATION_ID";
            NSDictionary *const userInfo = @{ @"foo": @"bar" };
            AMPPushNotificationPayload *__block parsedPayload = nil;

            beforeEach(^{
                parsedPayload = [AMPPushNotificationPayload nullMock];
                [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:parsedPayload];
                [parsedPayload stub:@selector(notificationID) andReturn:notificationID];
                [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(YES)];
            });

            context(@"Invalid payload", ^{
                beforeEach(^{
                    [payloadValidator stub:@selector(isPayloadValidForTracking:) andReturn:theValue(NO)];
                });

                it(@"Should not store push in pending", ^{
                    [[pendingPushController shouldNot] receive:@selector(handlePendingPushReceivingWithNotificationID:)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should not report directly", ^{
                    [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });
            });

            context(@"Caching enabled", ^{
                it(@"Should parse payload", ^{
                    [[payloadParser should] receive:@selector(pushNotificationPayloadFromDictionary:) withArguments:userInfo];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should not report directly", ^{
                    [[eventsController shouldNot] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should not send events buffer", ^{
                    [[eventsController shouldNot] receive:@selector(sendEventsBuffer)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should store push in pending", ^{
                    [[pendingPushController should] receive:@selector(handlePendingPushReceivingWithNotificationID:)
                                              withArguments:notificationID];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                context(@"With ID", ^{
                    it(@"Should store push in pending", ^{
                        [[pendingPushController should] receive:@selector(handlePendingPushReceivingWithNotificationID:)
                                                  withArguments:notificationID];
                        [notificationsController handleDidReceiveNotificationWithNotificationID:notificationID];
                    });
                    it(@"Should call strategy", ^{
                        [[notifyStrategy should] receive:@selector(handlePushNotification)];
                        [notificationsController handleDidReceiveNotificationWithNotificationID:notificationID];
                    });
                });
            });

            context(@"Caching disabled", ^{
                beforeEach(^{
                    [notificationsController disableEventsCaching];
                });

                it(@"Should parse payload", ^{
                    [[payloadParser should] receive:@selector(pushNotificationPayloadFromDictionary:) withArguments:userInfo];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should report push received", ^{
                    [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                         withArguments:notificationID, kAMPEventsControllerActionTypeReceive, nil, kw_any()];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should report push shown", ^{
                    [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                         withArguments:notificationID, kAMPEventsControllerActionTypeShown, nil, kw_any()];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should send events buffer", ^{
                    [[eventsController should] receive:@selector(sendEventsBuffer)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                it(@"Should not store push in pending", ^{
                    [[pendingPushController shouldNot] receive:@selector(handlePendingPushReceivingWithNotificationID:)];
                    [notificationsController handleDidReceiveNotificationRequestWithUserInfo:userInfo];
                });

                context(@"With ID", ^{
                    it(@"Should report push received", ^{
                        [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                             withArguments:notificationID, kAMPEventsControllerActionTypeReceive, nil, kw_any()];
                        [notificationsController handleDidReceiveNotificationWithNotificationID:notificationID];
                    });

                    it(@"Should report push shown", ^{
                        [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                             withArguments:notificationID, kAMPEventsControllerActionTypeShown, nil, kw_any()];
                        [notificationsController handleDidReceiveNotificationWithNotificationID:notificationID];
                    });

                    it(@"Should send events buffer", ^{
                        [[eventsController should] receive:@selector(sendEventsBuffer)];
                        [notificationsController handleDidReceiveNotificationWithNotificationID:notificationID];
                    });
                });
            });

        });

    });

    context(@"User data", ^{

        NSString *const userData = @"DATA";
        AMPPushNotificationPayload *__block payload = nil;

        beforeEach(^{
            payload = [AMPPushNotificationPayload nullMock];
            [payload stub:@selector(userData) andReturn:userData];
            [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:payload];
        });

        it(@"Should parse payload", ^{
            [[payloadParser should] receive:@selector(pushNotificationPayloadFromDictionary:)];
            [notificationsController userDataForNotification:@{}];
        });

        it(@"Should return nil for invalid info", ^{
            [payloadValidator stub:@selector(isPayloadValidForUserDataProviding:) andReturn:theValue(NO) withArguments:payload];

            NSString *result = [notificationsController userDataForNotification:@{}];
            [[result should] beNil];
        });

        it(@"Should return actual user data for valid info", ^{
            [payloadValidator stub:@selector(isPayloadValidForUserDataProviding:) andReturn:theValue(YES) withArguments:payload];

            NSString *result = [notificationsController userDataForNotification:@{}];
            [[result should] equal:userData];
        });

    });

    context(@"Is related to SDK", ^{

        NSDictionary *const notification = @{ @"foo": @"bar" };
        AMPPushNotificationPayload *__block payload = nil;

        beforeEach(^{
            payload = [AMPPushNotificationPayload nullMock];
            [payloadParser stub:@selector(pushNotificationPayloadFromDictionary:)
                      andReturn:payload
                  withArguments:notification];
        });

        it(@"Should return YES if payload is valid", ^{
            [payloadValidator stub:@selector(isPayloadGenerallyValid:)
                         andReturn:theValue(YES)
                     withArguments:payload];
            BOOL isRelated = [notificationsController isNotificationRelatedToSDK:notification];
            [[theValue(isRelated) should] beYes];
        });

        it(@"Should return NO if payload is invalid", ^{
            [payloadValidator stub:@selector(isPayloadGenerallyValid:)
                         andReturn:theValue(NO)
                     withArguments:payload];
            BOOL isRelated = [notificationsController isNotificationRelatedToSDK:notification];
            [[theValue(isRelated) should] beNo];
        });

    });

    context(@"Set extension app group", ^{
        it(@"Should call pendingPushController", ^{
            NSString *extensionAppGroup = @"extensionAppGroup";
            [[pendingPushController should] receive:@selector(updateExtensionAppGroup:)
                                      withArguments:extensionAppGroup];
            [notificationsController setExtensionAppGroup:extensionAppGroup];
        });
    });
    
    context(@"Notify about pending pushes", ^{

        it(@"Should call notifyAboutPendingPushes after handleApplicationDidFinishLaunchingWithOptions call", ^{
            [[pendingPushController should] receive:@selector(notifyAboutPendingPushes)];
            [notificationsController handleApplicationDidFinishLaunchingWithOptions:nil];
        });

        if (@available(iOS 13.0, *)) {
            it(@"Should call notifyAboutPendingPushes after handleSceneWillConnectToSessionWithOptions call", ^{
                [[pendingPushController should] receive:@selector(notifyAboutPendingPushes)];
                [notificationsController handleSceneWillConnectToSessionWithOptions:nil];
            });
        }
        
        it(@"Should call notifyAboutPendingPushes after setDeviceTokenFromData call", ^{
            [[pendingPushController should] receive:@selector(notifyAboutPendingPushes)];
            [notificationsController setDeviceTokenFromData:nil pushEnvironment:AMPAppMetricaPushEnvironmentDevelopment];
        });

        context(@"Application state change", ^{
            it(@"Should call notifyAboutPendingPushes after entering foreground", ^{
                [[pendingPushController should] receive:@selector(notifyAboutPendingPushes)];
                [notificationsController applicationStateProvider:applicationStateProvider
                                                   didChangeState:AMPApplicationStateForeground];
            });

            it(@"Should not call notifyAboutPendingPushes after entering background", ^{
                [[pendingPushController shouldNot] receive:@selector(notifyAboutPendingPushes)];
                [notificationsController applicationStateProvider:applicationStateProvider
                                                   didChangeState:AMPApplicationStateBackground];
            });
        });
    });

    context(@"Custom URL open queue", ^{

        dispatch_queue_t const queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        it(@"Should set custom queue in URL handler", ^{
            KWCaptureSpy *spy = [targetURLHandler captureArgument:@selector(setExecutor:) atIndex:0];
            [notificationsController setURLOpenDispatchQueue:queue];
            AMPDispatchQueueWhenActiveStateExecutor *executor = spy.argument;
            [[executor.queue should] equal:queue];
        });

    });

    context(@"Pending push handled", ^{
        NSString *const notificationID = @"notificationID";
        AMPPendingPush *__block pendingPush = nil;

        beforeEach(^{
            pendingPush = [[AMPPendingPush alloc] initWithNotificationID:notificationID receivingDate:[NSDate date]];
        });

        it(@"Should report push received", ^{
            [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                 withArguments:notificationID, kAMPEventsControllerActionTypeReceive, nil, kw_any()];
            [notificationsController pendingPushController:pendingPushController didNotifyPendingPush:pendingPush];
        });

        it(@"Should report push shown", ^{
            [[eventsController should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                 withArguments:notificationID, kAMPEventsControllerActionTypeShown, nil, kw_any()];
            [notificationsController pendingPushController:pendingPushController didNotifyPendingPush:pendingPush];
        });
    });
    
    context(@"Notify strategy when receive new notification", ^{
        
        id<AMPPendingNotificationStrategyDelegate> (^nc)() = ^{ return (id<AMPPendingNotificationStrategyDelegate>)notificationsController; };
        
        context(@"in app", ^{
            beforeEach(^{
                [applicationStateProvider stub:@selector(isRunningInExtension) andReturn:theValue(NO)];
            });
            
            it(@"should not call notify about pending push", ^{
                [[pendingPushController should] receive:@selector(notifyAboutPendingPushes)];
                [nc() pendingNotificationStrategyDidRequestPush:notifyStrategy];
            });
            
        });
        
    });

});

SPEC_END
