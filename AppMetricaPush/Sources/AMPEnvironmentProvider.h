
#import <Foundation/Foundation.h>
#import "AMPAppMetricaPushEnvironment.h"

@interface AMPEnvironmentProvider : NSObject

- (NSDictionary *)commonEnvironment;
- (NSDictionary *)notificationEventEnvironment;
- (NSDictionary *)tokenEventEnvironmentForPushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment;

@end
