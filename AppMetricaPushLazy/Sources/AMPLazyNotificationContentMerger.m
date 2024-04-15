
#import <UserNotifications/UserNotifications.h>
#import "AMPLazyNotificationContentMerger.h"


@implementation AMPLazyNotificationContentMerger

+ (UNNotificationContent *)mergeNotificationContent:(UNNotificationContent *)content
                                      andDictionary:(NSDictionary *)dictionary
{
    UNMutableNotificationContent *mutableContent = (UNMutableNotificationContent *) [content mutableCopy];

    [self mergeApsForNotificationContent:mutableContent
                           andDictionary:dictionary[@"aps"]];
    [self mergeYampForNotificationContent:mutableContent
                            andDictionary:dictionary[@"yamp"]];

    return mutableContent;
}

+ (void)mergeApsForNotificationContent:(UNMutableNotificationContent *)content
                         andDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]] == NO) {
        return;
    }

    NSDictionary *alert = dictionary[@"alert"];
    if ([alert isKindOfClass:[NSDictionary class]] == NO) {
        return;
    }

    NSString *title = alert[@"title"];
    if ([title isKindOfClass:[NSString class]]) {
        content.title = title;
    }

    NSString *subtitle = alert[@"subtitle"];
    if ([subtitle isKindOfClass:[NSString class]]) {
        content.subtitle = subtitle;
    }

    NSString *body = alert[@"body"];
    if ([body isKindOfClass:[NSString class]]) {
        content.body = body;
    }

    NSNumber *badge = alert[@"badge"];
    if ([badge isKindOfClass:[NSNumber class]]) {
        content.badge = badge;
    }
}

+ (void)mergeYampForNotificationContent:(UNMutableNotificationContent *)content
                          andDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]] == NO) {
        return;
    }

    content.userInfo = @{
        @"yamp": [[self class] mergeDictionary:content.userInfo[@"yamp"]
                                withDictionary:dictionary],
    };
}

+ (NSDictionary *)mergeDictionary:(NSDictionary *)first
                   withDictionary:(NSDictionary *)second
{
    if (first == nil) {
        return second;
    }
    if (second == nil) {
        return first;
    }
    NSMutableDictionary *result = [first mutableCopy];
    for (NSString *key in second) {
        if ([second[key] isKindOfClass:[NSDictionary class]] && [first[key] isKindOfClass:[NSDictionary class]]) {
            result[key] = [[self class] mergeDictionary:first[key]
                                         withDictionary:second[key]];
        }
        else {
            result[key] = second[key];
        }
    }
    return result;
}

@end
