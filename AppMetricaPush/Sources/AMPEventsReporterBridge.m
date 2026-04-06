
#import "AMPEventsReporterBridge.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreExtension/AppMetricaCoreExtension.h>

#import "AMPAnalyticsProxy.h"

@interface AMPEventsReporterBridge ()

@property (nonatomic, strong, readonly, nonnull) AMPAnalyticsProxy *analyticsProxy;

@end


@implementation AMPEventsReporterBridge

- (instancetype)initWithAnalyticsProxy:(AMPAnalyticsProxy *)analyticsProxy
{
    self = [super init];
    if (self) {
        _analyticsProxy = analyticsProxy;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithAnalyticsProxy:[AMPAnalyticsProxy sharedInstance]];
}

- (void)reportEventWithType:(NSUInteger)eventType
                       name:(NSString *)name
                      value:(NSString *)value
                environment:(NSDictionary *)environment
                  onFailure:(void (^)(NSError *error))onFailure
{
    [self.analyticsProxy activate];

    [AMAAppMetrica reportEventWithType:eventType
                                  name:name
                                 value:value
                      eventEnvironment:environment
                        appEnvironment:nil
                                extras:nil
                             onFailure:onFailure];
}

@end
