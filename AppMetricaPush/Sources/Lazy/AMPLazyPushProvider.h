
#import <Foundation/Foundation.h>
#import "AMPLazyPushProviding.h"

NS_ASSUME_NONNULL_BEGIN

@interface AMPLazyPushProvider : NSObject<AMPLazyPushProviding>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

- (void)setupPushProvider:(id<AMPLazyPushProviding>)provider;

@end

NS_ASSUME_NONNULL_END
