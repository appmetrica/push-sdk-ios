
#import "AMPEventsReporterBridge.h"

typedef void(^AMPEventsReporterBridgeMockOnFailure)(NSError *error);

@interface AMPEventsReporterBridgeMock : AMPEventsReporterBridge

@property (nonatomic, assign, readonly) NSUInteger lastReportedEventType;
@property (nonatomic, copy, readonly) NSString *lastReportedEventName;
@property (nonatomic, copy, readonly) NSString *lastReportedEventValue;
@property (nonatomic, copy, readonly) NSDictionary *lastReportedEventEnvironment;
@property (nonatomic, strong, readonly) AMPEventsReporterBridgeMockOnFailure lastOnFailureBlock;

@end
