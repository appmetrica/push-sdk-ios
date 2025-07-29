
#import <Kiwi/Kiwi.h>

#import "AMPEventsController.h"
#import "AMPEventsReporterMock.h"
#import "AMPEnvironmentProvider.h"
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPTokenEvent.h"
#import "AMPTokenEventValueSerializer.h"

SPEC_BEGIN(AMPEventsControllerTests)

describe(@"AMPEventsController", ^{

    AMPEventsController *__block controller = nil;
    AMPEventsReporterMock *__block reporter = nil;
    AMPEnvironmentProvider *__block provider = nil;

    AMPLibraryAnalyticsTracker *__block libraryTracker = nil;

    AMPAppMetricaPushEnvironment const pushEnvironment = AMPAppMetricaPushEnvironmentProduction;
    NSDictionary *const tokenEnvironment = @{ @"foo" : @"bar" };
    NSDictionary *const notificationEnvironment = @{ @"bar" : @"foo" };

    beforeEach(^{
        reporter = [[AMPEventsReporterMock alloc] init];
        provider = [AMPEnvironmentProvider nullMock];
        libraryTracker = [AMPLibraryAnalyticsTracker nullMock];

        controller = [[AMPEventsController alloc] initWithReporter:reporter
                                               environmentProvider:provider
                                           libraryAnalyticsTracker:libraryTracker];

        [provider stub:@selector(tokenEventEnvironmentForPushEnvironment:) andReturn:tokenEnvironment];
        [provider stub:@selector(notificationEventEnvironment) andReturn:notificationEnvironment];
    });

    context(@"Before AppMetrica activation", ^{

        it(@"Should check error on token sending failure", ^{
            AMPTokenEvent *tokenModel = [[AMPTokenEvent alloc] initWithToken:@"" enabled:YES notifications:nil];
            [[reporter should] receive:@selector(isReporterNotActivatedError:)];
            [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
            reporter.lastOnFailureBlock(reporter.notActivatedError);
        });

        it(@"Should raise on device token reporting", ^{
            [[theBlock(^{
                AMPTokenEvent *tokenModel = [[AMPTokenEvent alloc] initWithToken:@"TOKEN" enabled:YES notifications:nil];
                [controller reportDeviceTokenWithModel:tokenModel
                                       pushEnvironment:pushEnvironment
                                             onFailure:nil];
                reporter.lastOnFailureBlock(reporter.notActivatedError);
            }) should] raise];
        });

        it(@"Should not raise on push notification reporting", ^{
            [[theBlock(^{
                [controller reportPushNotificationWithNotificationID:@"ID"
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:nil];
                reporter.lastOnFailureBlock(reporter.notActivatedError);
            }) shouldNot] raise];
        });

    });

    context(@"Device Token", ^{
        AMPTokenEvent *const tokenModel = [[AMPTokenEvent alloc] initWithToken:@"token" enabled:YES notifications:nil];
        NSString *const value = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];

        it(@"Should report actual token", ^{
            [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
            [[reporter.lastReportedDeviceValue should] equal:value];
        });

        it(@"Should report token with actual environment", ^{
            [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
            [[reporter.lastReportedEventEnvironment should] equal:tokenEnvironment];
        });

        it(@"Should start library session before token reporting", ^{
            BOOL __block sessionStartedBeforeReporting = NO;
            [libraryTracker stub:@selector(resumeSession) withBlock:^id(NSArray *params) {
                if (reporter.lastReportedDeviceValue == nil) {
                    sessionStartedBeforeReporting = YES;
                }
                return nil;
            }];
            [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
            [[theValue(sessionStartedBeforeReporting) should] beYes];
        });

        context(@"Reporting error", ^{

            NSError *const reportingError = [NSError nullMock];

            it(@"Should track reporting error", ^{
                [[libraryTracker should] receive:@selector(reportMetricaSendingEventError:) withArguments:reportingError];
                [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:nil];
                reporter.lastOnFailureBlock(reportingError);
            });

            it(@"Should call onFailure with reporting error", ^{
                NSError *__block resultError = nil;
                [controller reportDeviceTokenWithModel:tokenModel pushEnvironment:pushEnvironment onFailure:^(NSError *error) {
                    resultError = error;
                }];
                reporter.lastOnFailureBlock(reportingError);
                [[resultError should] equal:reportingError];
            });

        });

    });

    context(@"Notification", ^{

        context(@"Empty notification id", ^{

            it(@"Should not report notification", ^{
                [[reporter shouldNot] receive:@selector(reportPushNotification:environment:onFailure:)];
                [controller reportPushNotificationWithNotificationID:@""
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:nil];
            });

            it(@"Should track reporting fact", ^{
                [[libraryTracker should] receive:@selector(reportInvalidNotification:withReason:)
                                   withArguments:nil, @"no_notification_id"];
                [controller reportPushNotificationWithNotificationID:@""
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:nil];
            });

        });

        context(@"Notification dictionary", ^{

            NSString *notificationID = @"NOTIFICATION_ID";
            NSString *actionType = @"TYPE";
            NSString *actionID = @"ACTION_ID";
            NSString *uri = @"https://appmetrica.io/push";

            beforeEach(^{
                [controller reportPushNotificationWithNotificationID:notificationID
                                                          actionType:actionType
                                                            actionID:actionID
                                                                 uri:uri
                                                           onFailure:nil];
            });

            it(@"Should format dictionary with correct notification ID", ^{
                [[reporter.lastReportedNotification[@"notification_id"] should] equal:notificationID];
            });

            it(@"Should format dictionary with correct action type", ^{
                [[reporter.lastReportedNotification[@"action"][@"type"] should] equal:actionType];
            });

            it(@"Should format dictionary with correct action ID", ^{
                [[reporter.lastReportedNotification[@"action"][@"id"] should] equal:actionID];
            });
            
            it(@"Should report notification with uri", ^{
                [[reporter.lastReportedNotification[@"action"][@"uri"] should] equal:uri];
            });

            it(@"Should report notification with actual environment", ^{
                [[reporter.lastReportedEventEnvironment should] equal:notificationEnvironment];
            });

        });

        context(@"Reporting error", ^{

            NSError *const reportingError = [NSError nullMock];

            it(@"Should track metrica not activated error", ^{
                [[libraryTracker should] receive:@selector(reportMetricaNotActivatedForAction:)
                                   withArguments:@"report_push_notification"];
                [controller reportPushNotificationWithNotificationID:@"ID"
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:nil];
                reporter.lastOnFailureBlock(reporter.notActivatedError);
            });

            it(@"Should track reporting error", ^{
                [[libraryTracker should] receive:@selector(reportMetricaSendingEventError:) withArguments:reportingError];
                [controller reportPushNotificationWithNotificationID:@"ID"
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:nil];
                reporter.lastOnFailureBlock(reportingError);
            });

            it(@"Should call onFailure with reporting error", ^{
                NSError *__block resultError = nil;
                [controller reportPushNotificationWithNotificationID:@"ID"
                                                          actionType:@"open"
                                                            actionID:nil
                                                                 uri:nil
                                                           onFailure:^(NSError *error) {
                    resultError = error;
                }];
                reporter.lastOnFailureBlock(reportingError);
                [[resultError should] equal:reportingError];
            });
            
        });
        
    });

    context(@"Send events buffer", ^{

        it(@"Should call sendEventsBuffer", ^{
            [[reporter should] receive:@selector(sendEventsBuffer)];
            [controller sendEventsBuffer];
        });

    });
    
});

SPEC_END
