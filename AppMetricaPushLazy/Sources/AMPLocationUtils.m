
#import <CoreLocation/CoreLocation.h>
#import "AMPLocationUtils.h"


@implementation AMPLocationUtils

+ (BOOL)isRelevantLocation:(CLLocation *)location
                minRecency:(NSTimeInterval)minRecency
               minAccurary:(CLLocationAccuracy)minAccuracy
{
    BOOL result = YES;
    result = result && (location != nil);
    result = result && (minRecency == -1 || [self recencyOfLocation:location] < minRecency);
    result = result && (minAccuracy == -1 || [self accuracyIsAccurate:location.horizontalAccuracy minAccuracy:minAccuracy]);
    result = result && (minAccuracy == -1 || [self accuracyIsAccurate:location.verticalAccuracy minAccuracy:minAccuracy]);
    return result;
}

+ (NSTimeInterval)recencyOfLocation:(CLLocation *)location
{
    NSDate *locationDate = location.timestamp;
    NSDate *now = [NSDate date];
    return [now timeIntervalSinceDate:locationDate];
}

+ (BOOL)accuracyIsAccurate:(CLLocationAccuracy)accuracy
               minAccuracy:(CLLocationAccuracy)minAccuracy
{
    return 0 < accuracy && accuracy < minAccuracy;
}

@end
