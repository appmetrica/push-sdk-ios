
#import <Kiwi/Kiwi.h>
#import <UserNotifications/UserNotifications.h>

#import "AMPLazyNotificationContentMerger.h"

SPEC_BEGIN(AMPLazyNotificationContentMergerTests)

describe(@"AMPLazyNotificationContentMerger", ^{

    NSDictionary *initialYamp = @{
        @"yamp": @{
            @"string": @"string",
            @"changed string": @"string",
            @"number": @12,
            @"changed number": @42,
            @"dict": @{
                    @"string": @"string",
                    @"changed string": @"string",
                    @"number": @12,
                    @"changed number": @42,
            },
            @"first string": @"string value",
            @"first dict": @{
                    @"dict key": @"dict value",
            },
        },
    };
    NSDictionary *newYamp = @{
        @"yamp": @{
            @"changed string": @"changed string",
            @"changed number": @4242,
            @"dict": @{
                    @"changed string": @"changed string",
                    @"changed number": @4242,
            },
            @"new key": @"value",
            @"first string": @{
                    @"key": @"value"
            },
            @"first dict": @"string value",
        },
    };

    it(@"Should return merged if both are present", ^{
        NSDictionary *expectedYamp = @{
            @"yamp": @{
                @"string": @"string",
                @"changed string": @"changed string",
                @"number": @12,
                @"changed number": @4242,
                @"dict": @{
                        @"string": @"string",
                        @"changed string": @"changed string",
                        @"number": @12,
                        @"changed number": @4242,
                },
                @"new key": @"value",
                @"first string": @{
                        @"key": @"value"
                },
                @"first dict": @"string value",
            },
        };
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.userInfo = initialYamp;

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:newYamp];
        [[result.userInfo should] equal:expectedYamp];
    });

    it(@"Should return unchanged if newYamp is nil", ^{
        NSDictionary *expectedYamp = initialYamp;

        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.userInfo = initialYamp;

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:nil];
        [[result.userInfo should] equal:expectedYamp];
    });

    it(@"Should return newYamp if userInfo is not present", ^{
        NSDictionary *expectedYamp = newYamp;

        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:newYamp];
        [[result.userInfo should] equal:expectedYamp];
    });

    it(@"Should change properties with aps", ^{
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Old title";
        content.subtitle = @"Old subtitle";
        content.body = @"Old body";
        content.badge = @1;

        NSDictionary *newYamp = @{
            @"aps": @{
                    @"alert": @{
                            @"title": @"New title",
                            @"subtitle": @"New subtitle",
                            @"body": @"New body",
                            @"badge": @42,
                    }
            },
        };

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:newYamp];
        [[result.title should] equal:@"New title"];
        [[result.subtitle should] equal:@"New subtitle"];
        [[result.body should] equal:@"New body"];
        [[result.badge should] equal:@42];
    });

    it(@"Should not change properties with wrong type", ^{
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Old title";
        content.subtitle = @"Old subtitle";
        content.body = @"Old body";
        content.badge = @1;

        NSDictionary *newYamp = @{
            @"aps": @{
                    @"alert": @{
                            @"title": @42,
                            @"subtitle": @43,
                            @"body": @44,
                            @"badge": @"New badge",
                    }
            },
        };

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:newYamp];
        [[result.title should] equal:@"Old title"];
        [[result.subtitle should] equal:@"Old subtitle"];
        [[result.body should] equal:@"Old body"];
        [[result.badge should] equal:@1];
    });

    it(@"Should change or not change properties with different type", ^{
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Old title";
        content.subtitle = @"Old subtitle";
        content.body = @"Old body";
        content.badge = @1;

        NSDictionary *newYamp = @{
            @"aps": @{
                    @"alert": @{
                            @"title": @42,
                            @"subtitle": @"New subtitle",
                            @"body": @44,
                            @"badge": @43,
                    }
            },
        };

        UNNotificationContent *result = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                     andDictionary:newYamp];
        [[result.title should] equal:@"Old title"];
        [[result.subtitle should] equal:@"New subtitle"];
        [[result.body should] equal:@"Old body"];
        [[result.badge should] equal:@43];
    });
});

SPEC_END
