
#import <Kiwi/Kiwi.h>
#import <CoreLocation/CoreLocation.h>
#import "AMPLocationProvider.h"
#import "AMPLocationUtils.h"


SPEC_BEGIN(AMPLastKnownLocationProviderTests)

describe(@"AMPLastKnownLocationProvider", ^{

    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(53.891059, 27.526119)
                                                         altitude:295.0
                                               horizontalAccuracy:1.0
                                                 verticalAccuracy:1.0
                                                        timestamp:[NSDate date]];
    CLLocationManager *__block manager = nil;

    beforeEach(^{
        manager = [CLLocationManager nullMock];
        [manager stub:@selector(location) andReturn:location];

        [AMPLocationUtils stub:@selector(isRelevantLocation:minRecency:minAccurary:) andReturn:theValue(YES)];
    });

    it(@"Should return correct location if authorizationStatus is always", ^{
        [manager stub:@selector(authorizationStatus) andReturn:theValue(kCLAuthorizationStatusAuthorizedAlways)];

        AMPLocationProvider *provider = [[AMPLocationProvider alloc] initWithLocationManager:manager];

        [[[provider locationWithMinRecency:1.0
                               minAccurary:1.0] should] equal:location];
    });

    it(@"Should return correct location if authorizationStatus is when in use", ^{
        [manager stub:@selector(authorizationStatus) andReturn:theValue(kCLAuthorizationStatusAuthorizedWhenInUse)];

        AMPLocationProvider *provider = [[AMPLocationProvider alloc] initWithLocationManager:manager];

        [[[provider locationWithMinRecency:1.0
                               minAccurary:1.0] should] equal:location];
    });

    it(@"Should return correct location if authorizationStatus is not always or when in use", ^{
        [manager stub:@selector(authorizationStatus) andReturn:theValue(kCLAuthorizationStatusDenied)];

        AMPLocationProvider *provider = [[AMPLocationProvider alloc] initWithLocationManager:manager];

        [[[provider locationWithMinRecency:1.0
                               minAccurary:1.0] should] beNil];
    });

    it(@"Should return nil if incorrect location", ^{
        [AMPLocationUtils stub:@selector(isRelevantLocation:minRecency:minAccurary:) andReturn:theValue(NO)];

        [manager stub:@selector(authorizationStatus) andReturn:theValue(kCLAuthorizationStatusAuthorizedAlways)];

        AMPLocationProvider *provider = [[AMPLocationProvider alloc] initWithLocationManager:manager];

        [[[provider locationWithMinRecency:1.0
                               minAccurary:1.0] should] beNil];
    });

    it(@"Should return nil if location services are not enabled", ^{
        [manager stub:@selector(locationServicesEnabled) andReturn:theValue(NO)];

        AMPLocationProvider *provider = [[AMPLocationProvider alloc] initWithLocationManager:manager];

        [[[provider locationWithMinRecency:1.0
                               minAccurary:1.0] should] beNil];
    });
});

SPEC_END
