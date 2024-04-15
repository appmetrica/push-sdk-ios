
#import <Foundation/Foundation.h>

@interface AMPEventsReporterBridge : NSObject

- (void)reportEventWithType:(NSUInteger)eventType
                       name:(NSString *)name
                      value:(NSString *)value
                environment:(NSDictionary *)environment
                  onFailure:(void (^)(NSError *error))onFailure;

@end
