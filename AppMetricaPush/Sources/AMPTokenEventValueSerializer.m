
#import "AMPTokenEventValueSerializer.h"
#import "AMPTokenEvent.h"
#import "AMPSubscribedNotification.h"

@implementation AMPTokenEventValueSerializer

+ (NSString *)dataWithTokenEvent:(AMPTokenEvent *)tokenModel
{
    NSMutableDictionary *types = [NSMutableDictionary dictionary];
    for (AMPSubscribedNotification *notification in tokenModel.notifications) {
        types[notification.name] = @{ @"enabled" : @(notification.enabled) };
    }
    NSString *token = tokenModel.token ?: @"";
    NSDictionary *dict = @{
        @"token" : token,
        @"notifications_status" : @{
            @"enabled" : @(tokenModel.enabled),
            @"type" : types,
        },
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
