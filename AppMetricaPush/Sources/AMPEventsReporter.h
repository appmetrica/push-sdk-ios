
#import <Foundation/Foundation.h>

@class AMPEventsReporterBridge;

@interface AMPEventsReporter : NSObject

- (instancetype)initWithEventsReporterBridge:(AMPEventsReporterBridge *)bridge;

- (void)reportDeviceTokenWithValue:(NSString *)eventValue
                       environment:(NSDictionary *)environment
                         onFailure:(void (^)(NSError *))onFailure;

- (void)reportPushNotification:(NSDictionary *)notification
                   environment:(NSDictionary *)environment
                     onFailure:(void (^)(NSError *error))onFailure;

- (void)sendEventsBuffer;

- (BOOL)isReporterNotActivatedError:(NSError *)error;

@end
