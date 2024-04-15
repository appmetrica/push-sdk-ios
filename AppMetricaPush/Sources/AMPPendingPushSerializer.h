
#import <Foundation/Foundation.h>

@class AMPPendingPush;

@interface AMPPendingPushSerializer : NSObject

+ (AMPPendingPush *)pushForDictionaty:(NSDictionary *)serializedPush;
+ (NSDictionary *)dictionaryForPush:(AMPPendingPush *)push;

@end
