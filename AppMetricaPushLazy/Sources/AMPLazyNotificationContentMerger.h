
#import <Foundation/Foundation.h>

@class UNNotificationContent;


@interface AMPLazyNotificationContentMerger : NSObject

+ (UNNotificationContent *)mergeNotificationContent:(UNNotificationContent *)content
                                      andDictionary:(NSDictionary *)dictionary;

@end
