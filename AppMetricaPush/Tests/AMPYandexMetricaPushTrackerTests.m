
#import <Kiwi/Kiwi.h>

#import "AMPAppMetricaPushTracker.h"
#import "AMPEventsController.h"
#import "AMPPushNotificationController.h"

SPEC_BEGIN(AMPAppMetricaPushTrackerTests)

describe(@"AMPAppMetricaPushTracker", ^{

    NSString *const notificationID = @"NOTIFICATION_ID";
    NSString *const uri = @"https://appmetrica.io/push";

    AMPEventsController *__block controller = nil;
    AMPPushNotificationController *__block pushController = nil;

    beforeEach(^{
        controller = [AMPEventsController nullMock];
        [AMPEventsController stub:@selector(sharedInstance) andReturn:controller];
        pushController = [AMPPushNotificationController nullMock];
        [AMPPushNotificationController stub:@selector(sharedInstance) andReturn:pushController];
    });
    afterEach(^{
        [AMPEventsController clearStubs];
        [AMPPushNotificationController clearStubs];
    });

    context(@"Receive", ^{
        
        it(@"reportReceive", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"receive", nil, nil, block];
            
            [AMPAppMetricaPushTracker reportReceive:notificationID onFailure:block];
        });
        
    });

    context(@"Open", ^{

        it(@"reportOpen", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"open", nil, nil, block];
            
            [AMPAppMetricaPushTracker reportOpen:notificationID onFailure:block];
        });
        
        it(@"reportOpen and uri", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"open", nil, uri, block];
            
            [AMPAppMetricaPushTracker reportOpen:notificationID uri:uri onFailure:block];
        });

    });

    context(@"Dismiss", ^{

        it(@"reportDismiss", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"dismiss", nil, nil, block];
            
            [AMPAppMetricaPushTracker reportDismiss:notificationID onFailure:block];
        });
        
    });

    context(@"Custom", ^{

        NSString *const actionID = @"ACTION_ID";
        
        it(@"reportAdditionalAction", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"custom", actionID, nil, block];
            
            [AMPAppMetricaPushTracker reportAdditionalAction:actionID notificationID:notificationID onFailure:block];
        });

    });

    context(@"Processed", ^{
        
        it(@"reportProcess", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[controller should] receive:@selector(reportPushNotificationWithNotificationID:actionType:actionID:uri:onFailure:)
                           withArguments:notificationID, @"processed", nil, nil, block];
            
            [AMPAppMetricaPushTracker reportProcess:notificationID onFailure:block];
        });
        
    });

    context(@"Received in extension", ^{
        
        it(@"reportReceiveInExtension", ^{
            AMPAppMetricaPushTrackerReportFailure block = ^(NSError *error){};
            
            [[pushController should] receive:@selector(handleDidReceiveNotificationWithNotificationID:)
                               withArguments:notificationID];
            [AMPAppMetricaPushTracker reportReceiveInExtension:notificationID onFailure:block];
        });
        
    });
    
});

SPEC_END
