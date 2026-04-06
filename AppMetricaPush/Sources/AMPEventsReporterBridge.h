
#import <Foundation/Foundation.h>

@class AMPAnalyticsProxy;

NS_ASSUME_NONNULL_BEGIN

@interface AMPEventsReporterBridge : NSObject

- (instancetype)initWithAnalyticsProxy:(AMPAnalyticsProxy *)analyticsProxy NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

- (void)reportEventWithType:(NSUInteger)eventType
                       name:(NSString *)name
                      value:(NSString *)value
                environment:(NSDictionary *)environment
                  onFailure:(void (^)(NSError *error))onFailure;

@end

NS_ASSUME_NONNULL_END
