
#import <Kiwi/Kiwi.h>

#import "AMPEventsReporterMock.h"

@interface AMPEventsReporterMock ()

@property (nonatomic, copy) NSString *lastReportedDeviceValue;
@property (nonatomic, copy) NSDictionary *lastReportedNotification;
@property (nonatomic, copy) NSDictionary *lastReportedEventEnvironment;
@property (nonatomic, strong) AMPEventsReporterMockOnFailure lastOnFailureBlock;

@end

@implementation AMPEventsReporterMock

- (NSError *)notActivatedError
{
    static NSError *metricaNotActivatedError = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        metricaNotActivatedError = [NSError nullMock];
    });
    return metricaNotActivatedError;
}

- (void)reportDeviceTokenWithValue:(NSString *)eventValue
                       environment:(NSDictionary *)environment
                         onFailure:(void (^)(NSError *error))onFailure
{
    self.lastReportedDeviceValue = eventValue;
    [self reportCommonEventWithEnvironment:environment onFailure:onFailure];
}

- (void)reportPushNotification:(NSDictionary *)notification
                   environment:(NSDictionary *)environment
                     onFailure:(void (^)(NSError *error))onFailure
{
    self.lastReportedNotification = notification;
    [self reportCommonEventWithEnvironment:environment onFailure:onFailure];
}

- (void)reportCommonEventWithEnvironment:(NSDictionary *)environment
                               onFailure:(void (^)(NSError *error))onFailure
{
    self.lastReportedEventEnvironment = environment;
    self.lastOnFailureBlock = onFailure;
}

- (BOOL)isReporterNotActivatedError:(NSError *)error
{
    return [error isEqual:self.notActivatedError];
}

@end
