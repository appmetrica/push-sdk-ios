
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AMPLocationProvider : NSObject

+ (instancetype)sharedInstance;

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager;

- (CLLocation *)locationWithMinRecency:(NSTimeInterval)minRecency
                           minAccurary:(CLLocationAccuracy)minAccuracy;

@end
