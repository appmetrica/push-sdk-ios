
#import <Foundation/Foundation.h>

@class AMPTokenEvent;

@interface AMPTokenEventModelProvider : NSObject

+ (void)retrieveTokenEventWithToken:(NSString *)token block:(void(^)(AMPTokenEvent *tokenModel))block;

@end
