
#import "AMPLocationProvider.h"
#import "AMPLocationUtils.h"


@interface AMPLocationProvider ()

@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@end

@implementation AMPLocationProvider


+ (instancetype)sharedInstance
{
    static AMPLocationProvider *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AMPLocationProvider alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithLocationManager:[[CLLocationManager alloc] init]];
}

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
{
    self = [super init];
    if (self != nil) {
        _locationManager = locationManager;
    }
    return self;
}

- (CLLocation *)locationWithMinRecency:(NSTimeInterval)minRecency
                           minAccurary:(CLLocationAccuracy)minAccuracy
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return nil;
    }

    CLAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = [self.locationManager authorizationStatus];
    }
    else {
        status = [CLLocationManager authorizationStatus];
    }

    if (status != kCLAuthorizationStatusAuthorizedWhenInUse && status != kCLAuthorizationStatusAuthorizedAlways) {
        return nil;
    }

    CLLocation *location = [self.locationManager location];
    if ([AMPLocationUtils isRelevantLocation:location
                                  minRecency:minRecency
                                 minAccurary:minAccuracy]) {
        return location;
    }

    return nil;
}

@end
