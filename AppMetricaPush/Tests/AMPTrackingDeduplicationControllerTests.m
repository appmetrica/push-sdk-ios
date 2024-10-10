
#import <Kiwi/Kiwi.h>
#import "AMPTrackingDeduplicationController.h"
#import "AMPPushNotificationPayload.h"
#import "AMPAttachmentPayload.h"

SPEC_BEGIN(AMPTrackingDeduplicationControllerTests)

describe(@"AMPTrackingDeduplicationController", ^{

    NSString *const notificationID = @"NOTIFICATION_ID";

    AMPPushNotificationPayload *__block payload = nil;
    AMPTrackingDeduplicationController *__block controller = nil;

    beforeEach(^{
        controller = [[AMPTrackingDeduplicationController alloc] init];
    });

    context(@"Valid payload", ^{
        beforeEach(^{
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:notificationID
                                                                       targetURL:nil
                                                                        userData:nil
                                                                     attachments:nil
                                                                          silent:NO
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
        });
        it(@"Should retrurn YES for firstly met push", ^{
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });

        it(@"Should retrurn NO for already met push", ^{
            [controller markEventReportedForNotification:payload];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beNo];
        });

        it(@"Should retrurn NO for another push with same ID", ^{
            [controller markEventReportedForNotification:payload];
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:notificationID
                                                                       targetURL:@"https://ya.ru"
                                                                        userData:@"USER_DATA"
                                                                     attachments:@[ [AMPAttachmentPayload nullMock] ]
                                                                          silent:YES
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beNo];
        });

        it(@"Should retrurn YES for another push with different ID", ^{
            [controller markEventReportedForNotification:payload];
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:@"DIFFERENT_NOTIFICATION_ID"
                                                                       targetURL:nil
                                                                        userData:nil
                                                                     attachments:nil
                                                                          silent:NO
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });
    });

    context(@"No notification ID", ^{
        beforeEach(^{
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                       targetURL:nil
                                                                        userData:nil
                                                                     attachments:nil
                                                                          silent:NO
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
        });
        it(@"Should retrurn YES for firstly met push", ^{
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });

        it(@"Should retrurn YES for already met push", ^{
            [controller markEventReportedForNotification:payload];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });

        it(@"Should retrurn YES for another push with different ID", ^{
            [controller markEventReportedForNotification:payload];
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:@"DIFFERENT_NOTIFICATION_ID"
                                                                       targetURL:nil
                                                                        userData:nil
                                                                     attachments:nil
                                                                          silent:NO
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });
    });

    context(@"Nil payload", ^{
        beforeEach(^{
            payload = nil;
        });
        it(@"Should retrurn NO for firstly met push", ^{
            [[theValue([controller shouldReportEventForNotification:payload]) should] beNo];
        });

        it(@"Should retrurn NO for already met push", ^{
            [controller markEventReportedForNotification:payload];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beNo];
        });

        it(@"Should retrurn YES for another push with different ID", ^{
            [controller markEventReportedForNotification:payload];
            payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:@"DIFFERENT_NOTIFICATION_ID"
                                                                       targetURL:nil
                                                                        userData:nil
                                                                     attachments:nil
                                                                          silent:NO
                                                                  delCollapseIDs:@[]
                                                                            lazy:nil];
            [[theValue([controller shouldReportEventForNotification:payload]) should] beYes];
        });
    });

});

SPEC_END

