
#import <Foundation/Foundation.h>

@class AMPTokenEvent;

@interface AMPTokenEventValueSerializer : NSObject

+ (NSString *)dataWithTokenEvent:(AMPTokenEvent *)tokenModel;

@end
