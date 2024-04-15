
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AMPLocationUtils : NSObject

+ (BOOL)isRelevantLocation:(CLLocation *)location
                minRecency:(NSTimeInterval)minRecency
               minAccurary:(CLLocationAccuracy)minAccuracy;

@end
