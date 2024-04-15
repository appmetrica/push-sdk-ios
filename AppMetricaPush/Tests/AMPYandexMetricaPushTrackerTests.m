
#import <Kiwi/Kiwi.h>

#import "AMPAppMetricaPushTracker.h"
#import "AMPEventsController.h"
#import "AMPPushNotificationController.h"

SPEC_BEGIN(AMPAppMetricaPushTrackerTests)

describe(@"AMPAppMetricaPushTracker", ^{

    NSString *const notificationID = @"NOTIFICATION_ID";

    AMPEventsController *__block controller = nil;
    AMPPushNotificationController *__block pushController = nil;

    beforeEach(^{
        controller = [AMPEventsController nullMock];
        [AMPEventsController stub:@selector(sharedInstance) andReturn:controller];
        pushController = [AMPPushNotificationController nullMock];
        [AMPPushNotificationController stub:@selector(sharedInstance) andReturn:pushController];
    });

    context(@"Receive", ^{

        it(@"Should call events controller with proper notification id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:0];
            [AMPAppMetricaPushTracker reportReceive:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

        it(@"Should call events controller with proper action type", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:1];
            [AMPAppMetricaPushTracker reportReceive:notificationID onFailure:nil];
            [[spy.argument should] equal:@"receive"];
        });

        it(@"Should call events controller with nil action id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:2];
            [AMPAppMetricaPushTracker reportReceive:notificationID onFailure:nil];
            [[spy.argument should] beNil];
        });

        it(@"Should call events controller with same onFailure block", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:3];
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            [AMPAppMetricaPushTracker reportReceive:notificationID onFailure:block];
            [[spy.argument should] equal:block];
        });
        
    });

    context(@"Open", ^{

        it(@"Should call events controller with proper notification id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:0];
            [AMPAppMetricaPushTracker reportOpen:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

        it(@"Should call events controller with proper action type", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:1];
            [AMPAppMetricaPushTracker reportOpen:notificationID onFailure:nil];
            [[spy.argument should] equal:@"open"];
        });

        it(@"Should call events controller with nil action id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:2];
            [AMPAppMetricaPushTracker reportOpen:notificationID onFailure:nil];
            [[spy.argument should] beNil];
        });

        it(@"Should call events controller with same onFailure block", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:3];
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            [AMPAppMetricaPushTracker reportOpen:notificationID onFailure:block];
            [[spy.argument should] equal:block];
        });

    });

    context(@"Dismiss", ^{

        it(@"Should call events controller with proper notification id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:0];
            [AMPAppMetricaPushTracker reportDismiss:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

        it(@"Should call events controller with proper action type", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:1];
            [AMPAppMetricaPushTracker reportDismiss:notificationID onFailure:nil];
            [[spy.argument should] equal:@"dismiss"];
        });

        it(@"Should call events controller with nil action id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:2];
            [AMPAppMetricaPushTracker reportDismiss:notificationID onFailure:nil];
            [[spy.argument should] beNil];
        });

        it(@"Should call events controller with same onFailure block", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:3];
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            [AMPAppMetricaPushTracker reportDismiss:notificationID onFailure:block];
            [[spy.argument should] equal:block];
        });
        
    });

    context(@"Custom", ^{

        NSString *const actionID = @"ACTION_ID";

        it(@"Should call events controller with proper notification id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:0];
            [AMPAppMetricaPushTracker reportAdditionalAction:actionID notificationID:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

        it(@"Should call events controller with proper action type", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:1];
            [AMPAppMetricaPushTracker reportAdditionalAction:actionID notificationID:notificationID onFailure:nil];
            [[spy.argument should] equal:@"custom"];
        });

        it(@"Should call events controller with nil action id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:2];
            [AMPAppMetricaPushTracker reportAdditionalAction:actionID notificationID:notificationID onFailure:nil];
            [[spy.argument should] equal:actionID];
        });

        it(@"Should call events controller with same onFailure block", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:3];
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            [AMPAppMetricaPushTracker reportAdditionalAction:actionID notificationID:notificationID onFailure:block];
            [[spy.argument should] equal:block];
        });
        
    });

    context(@"Processed", ^{

        it(@"Should call events controller with proper notification id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:0];
            [AMPAppMetricaPushTracker reportProcess:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

        it(@"Should call events controller with proper action type", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:1];
            [AMPAppMetricaPushTracker reportProcess:notificationID onFailure:nil];
            [[spy.argument should] equal:@"processed"];
        });

        it(@"Should call events controller with nil action id", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:2];
            [AMPAppMetricaPushTracker reportProcess:notificationID onFailure:nil];
            [[spy.argument should] beNil];
        });

        it(@"Should call events controller with same onFailure block", ^{
            KWCaptureSpy *spy = [controller captureArgument:@selector(reportPushNotificationWithNotificationID:actionType:actionID:onFailure:)
                                                    atIndex:3];
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            [AMPAppMetricaPushTracker reportProcess:notificationID onFailure:block];
            [[spy.argument should] equal:block];
        });

    });

    context(@"Received in extension", ^{

        it(@"Should call pending controller with proper notification id", ^{
            KWCaptureSpy *spy =
                [pushController captureArgument:@selector(handleDidReceiveNotificationWithNotificationID:) atIndex:0];
            [AMPAppMetricaPushTracker reportReceiveInExtension:notificationID onFailure:nil];
            [[spy.argument should] equal:notificationID];
        });

    });
    
});

SPEC_END
