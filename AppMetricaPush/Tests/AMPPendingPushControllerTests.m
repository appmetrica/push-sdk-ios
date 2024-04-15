
#import <Kiwi/Kiwi.h>

#import "AMPEventsController.h"
#import "AMPEventsReporterMock.h"
#import "AMPEnvironmentProvider.h"
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPPendingPushController.h"
#import "AMPPendingPush.h"
#import "AMPPendingPushStorage.h"

SPEC_BEGIN(AMPPendingPushControllerTests)

describe(@"AMPPendingPushController", ^{

    AMPPendingPush *__block pendingPush = nil;
    AMPEventsController *__block eventsController = nil;
    NSObject<AMPPendingPushControllerDelegate> *__block delegate = nil;
    AMPPendingPushController *__block controller = nil;
    AMPPendingPushStorage *__block storage = nil;

    NSString *const notificationID = @"testNotificationID";

    beforeEach(^{
        pendingPush = [[AMPPendingPush alloc] initWithNotificationID:notificationID receivingDate:[NSDate date]];
        [pendingPush stub:@selector(initWithNotificationID:receivingDate:) andReturn:pendingPush];
        [AMPPendingPush stub:@selector(alloc) andReturn:pendingPush];

        storage = [AMPPendingPushStorage nullMock];
        [storage stub:@selector(initWithUserDefaults:) andReturn:storage];
        [AMPPendingPushStorage stub:@selector(alloc) andReturn:storage];

        eventsController = [AMPEventsController nullMock];
        [AMPEventsController stub:@selector(sharedInstance) andReturn:eventsController];

        delegate = [KWMock nullMockForProtocol:@protocol(AMPPendingPushControllerDelegate)];

        controller = [[AMPPendingPushController alloc] init];
        controller.delegate = delegate;
    });

    context(@"Handle pending pushes", ^{

        beforeEach(^{
            [controller updateExtensionAppGroup:@"appGroup"];
        });

        context(@"Handle pending pushes receiving", ^{

            it(@"Should create push with valid parameters", ^{
                NSDate *date = [NSDate date];
                [NSDate stub:@selector(date) andReturn:date];
                [[pendingPush should] receive:@selector(initWithNotificationID:receivingDate:)
                                withArguments:notificationID, date];
                [controller handlePendingPushReceivingWithNotificationID:notificationID];
            });

            it(@"Should put received push in userDefaults", ^{
                [[storage should] receive:@selector(addPendingPush:) withArguments:pendingPush];
                [controller handlePendingPushReceivingWithNotificationID:notificationID];
            });
        });


        context(@"Handle pending pushes notifying", ^{

            context(@"Notification", ^{
                beforeEach(^{
                    [storage stub:@selector(pendingPushes) andReturn:@[pendingPush]];
                });

                it(@"Should report to delegate", ^{
                    [[delegate should] receive:@selector(pendingPushController:didNotifyPendingPush:)
                                 withArguments:controller, pendingPush];
                    [controller notifyAboutPendingPushes];
                });
            });

            it(@"Should clean userDefaults after notifying", ^{
                [[storage should] receive:@selector(cleanup)];
                [controller notifyAboutPendingPushes];
            });
        });

    });

});

SPEC_END
