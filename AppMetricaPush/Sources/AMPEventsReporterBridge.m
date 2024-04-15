
#import "AMPEventsReporterBridge.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreExtension/AppMetricaCoreExtension.h>

@implementation AMPEventsReporterBridge

- (void)reportEventWithType:(NSUInteger)eventType
                       name:(NSString *)name
                      value:(NSString *)value
                environment:(NSDictionary *)environment
                  onFailure:(void (^)(NSError *error))onFailure
{
    [AMAAppMetrica reportEventWithType:eventType
                                  name:name
                                 value:value
                      eventEnvironment:environment
                        appEnvironment:nil
                                extras:nil
                             onFailure:onFailure];
}

@end
