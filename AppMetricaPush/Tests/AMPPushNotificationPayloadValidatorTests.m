
#import <Kiwi/Kiwi.h>

#import "AMPPushNotificationPayloadValidator.h"
#import "AMPPushNotificationPayload.h"

SPEC_BEGIN(AMPPushNotificationPayloadValidatorTests)

describe(@"AMPPushNotificationPayloadValidator", ^{

    let(validator, ^id{
        return [AMPPushNotificationPayloadValidator new];
    });

    context(@"General", ^{

        it(@"Should return NO on nil payload", ^{
            BOOL isValid = [validator isPayloadGenerallyValid:nil];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return YES on non-nil payload", ^{
            BOOL isValid = [validator isPayloadGenerallyValid:[[AMPPushNotificationPayload alloc] init]];
            [[theValue(isValid) should] beYes];
        });

    });

    context(@"Tracking", ^{

        it(@"Should return NO on nil payload", ^{
            BOOL isValid = [validator isPayloadValidForTracking:nil];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return NO on payload with empty notification ID", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:@""
                                                                                                   targetURL:nil
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForTracking:payload];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return YES on payload with non empty notification ID", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:@"h=1"
                                                                                                   targetURL:nil
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForTracking:payload];
            [[theValue(isValid) should] beYes];
        });

    });

    context(@"URL opening", ^{

        it(@"Should return NO on nil payload", ^{
            BOOL isValid = [validator isPayloadValidForURLOpening:nil];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return NO on payload with empty target URL", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:@""
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForURLOpening:payload];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return YES on payload with non empty target URL", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:@"https://ya.ru"
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForURLOpening:payload];
            [[theValue(isValid) should] beYes];
        });

        it(@"Should return NO for silent push", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:@"https://ya.ru"
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:YES
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForURLOpening:payload];
            [[theValue(isValid) should] beNo];
        });
        
    });

    context(@"User data providing", ^{

        it(@"Should return NO on nil payload", ^{
            BOOL isValid = [validator isPayloadValidForUserDataProviding:nil];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return NO on payload with nil user data", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:nil
                                                                                                    userData:nil
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForUserDataProviding:payload];
            [[theValue(isValid) should] beNo];
        });

        it(@"Should return YES on payload with empty user data", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:nil
                                                                                                    userData:@""
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForUserDataProviding:payload];
            [[theValue(isValid) should] beYes];
        });

        it(@"Should return YES on payload with non empty user data", ^{
            AMPPushNotificationPayload *payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                   targetURL:nil
                                                                                                    userData:@"data"
                                                                                                 attachments:nil
                                                                                                      silent:NO
                                                                                              delCollapseIDs:@[]
                                                                                                        lazy:nil];
            BOOL isValid = [validator isPayloadValidForUserDataProviding:payload];
            [[theValue(isValid) should] beYes];
        });
        
    });
    
});

SPEC_END
