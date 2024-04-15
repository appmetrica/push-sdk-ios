
#import <Kiwi/Kiwi.h>

#import "AMPPendingPush.h"
#import "AMPPendingPushSerializer.h"

static NSString *const kAMPNotificationIDKey = @"notificationID";
static NSString *const kAMPReceivingDateKey = @"receivingDate";

SPEC_BEGIN(AMPPendingPushSerializerTests)

describe(@"AMPPendingPushController", ^{

    context(@"Pending push serialization", ^{

        NSString *const notificationID = @"testNotificationID";

        AMPPendingPush *__block push = nil;
        NSDictionary *__block dict = nil;
        NSDate *__block date = nil;

        beforeEach(^{
            date = [NSDate date];
        });

        context(@"Should serialize push", ^{

            beforeEach(^{
                dict = @{ kAMPNotificationIDKey : notificationID , kAMPReceivingDateKey : date };
                push = [AMPPendingPushSerializer pushForDictionaty:dict];
            });

            it(@"Should serialize notificationID", ^{
                [[push.notificationID should] equal:notificationID];
            });

            it(@"Should serialize date", ^{
                [[push.receivingDate should] equal:date];
            });

        });

        context(@"Should deserialize push", ^{

            beforeEach(^{
                push = [[AMPPendingPush alloc] initWithNotificationID:notificationID receivingDate:date];
                dict = [AMPPendingPushSerializer dictionaryForPush:push];
            });

            it(@"Should serialize notificationID", ^{
                [[dict[kAMPNotificationIDKey] should] equal:notificationID];
            });

            it(@"Should serialize date", ^{
                [[dict[kAMPReceivingDateKey] should] equal:date];
            });

        });

    });

});

SPEC_END
