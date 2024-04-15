
#import <Kiwi/Kiwi.h>
#import "AMPPendingPushStorage.h"
#import "AMPPendingPush.h"
#import "AMPPendingPushSerializer.h"

static NSString *const kAMPPendingPushesKey = @"io.appmetrica.push.notifications.received";

SPEC_BEGIN(AMPPendingPushStorageTests)

describe(@"AMPPendingPushStorage", ^{

    AMPPendingPush *__block pendingPush = nil;
    NSDictionary *__block serializedPush = nil;
    
    NSUserDefaults *__block userDefaults = nil;
    AMPPendingPushStorage *__block storage = nil;

    beforeEach(^{
        pendingPush = [[AMPPendingPush alloc] initWithNotificationID:@"NotificationID"
                                                       receivingDate:[NSDate date]];
        serializedPush = @{
            @"notificationID": pendingPush.notificationID,
            @"receivingDate": pendingPush.receivingDate,
        };

        userDefaults = [NSUserDefaults nullMock];
        storage = [[AMPPendingPushStorage alloc] initWithUserDefaults:userDefaults];
    });

    it(@"Should put received push in userDefaults", ^{
        [[userDefaults should] receive:@selector(setObject:forKey:)
                         withArguments:@[serializedPush], kAMPPendingPushesKey];
        [storage addPendingPush:pendingPush];
    });

    context(@"Get stored pushes", ^{
        AMPPendingPush *__block storedPush = nil;
        beforeEach(^{
            [userDefaults stub:@selector(objectForKey:) andReturn:@[serializedPush] withArguments:kAMPPendingPushesKey];
            storedPush = [[storage pendingPushes] firstObject];
        });
        it(@"Should have valid id", ^{
            [[storedPush.notificationID should] equal:pendingPush.notificationID];
        });
        it(@"Should have valid date", ^{
            [[storedPush.receivingDate should] equal:pendingPush.receivingDate];
        });
    });

    it(@"Should clean userDefaults after notifying", ^{
        [[userDefaults should] receive:@selector(removeObjectForKey:) withArguments:kAMPPendingPushesKey];
        [storage cleanup];
    });

});

SPEC_END

