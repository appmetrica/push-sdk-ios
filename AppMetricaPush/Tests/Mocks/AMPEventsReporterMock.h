
#import "AMPEventsReporter.h"

typedef void(^AMPEventsReporterMockOnFailure)(NSError *error);

@interface AMPEventsReporterMock : AMPEventsReporter

@property (nonatomic, strong, readonly) NSError *notActivatedError;

@property (nonatomic, copy, readonly) NSString *lastReportedDeviceValue;
@property (nonatomic, copy, readonly) NSDictionary *lastReportedNotification;
@property (nonatomic, copy, readonly) NSDictionary *lastReportedEventEnvironment;
@property (nonatomic, strong, readonly) AMPEventsReporterMockOnFailure lastOnFailureBlock;

@end
