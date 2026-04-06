#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMPAnalyticsProxy : NSObject

+ (instancetype)sharedInstance;

- (void)activate;

@end

NS_ASSUME_NONNULL_END
