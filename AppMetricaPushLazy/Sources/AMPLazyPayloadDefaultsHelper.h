
#import <Foundation/Foundation.h>


@class AMPLazyPayload;

@interface AMPLazyPayloadDefaultsHelper : NSObject

+ (double)minRecency:(AMPLazyPayload *)lazyPayload;

+ (double)minAccuracy:(AMPLazyPayload *)lazyPayload;

@end
