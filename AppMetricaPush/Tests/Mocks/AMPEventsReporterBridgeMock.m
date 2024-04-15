
#import "AMPEventsReporterBridgeMock.h"

@interface AMPEventsReporterBridgeMock ()

@property (nonatomic, assign) NSUInteger lastReportedEventType;
@property (nonatomic, copy) NSString *lastReportedEventName;
@property (nonatomic, copy) NSString *lastReportedEventValue;
@property (nonatomic, copy) NSDictionary *lastReportedEventEnvironment;
@property (nonatomic, strong) AMPEventsReporterBridgeMockOnFailure lastOnFailureBlock;

@end

@implementation AMPEventsReporterBridgeMock

- (void)reportEventWithType:(NSUInteger)eventType
                       name:(NSString *)name
                      value:(NSString *)value
                environment:(NSDictionary *)environment
                  onFailure:(void (^)(NSError *error))onFailure
{
    self.lastReportedEventType = eventType;
    self.lastReportedEventName = name;
    self.lastReportedEventValue = value;
    self.lastReportedEventEnvironment = environment;
    self.lastOnFailureBlock = onFailure;
}

@end
