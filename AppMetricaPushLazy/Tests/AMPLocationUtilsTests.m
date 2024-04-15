
#import <Kiwi/Kiwi.h>
#import <CoreLocation/CoreLocation.h>
#import "AMPLocationUtils.h"

SPEC_BEGIN(AMPLocationUtilsTests)

describe(@"AMPLocationUtils", ^{
    it(@"Should return YES for correct location", ^{
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(53.891059, 27.526119)
                                                             altitude:295.0
                                                   horizontalAccuracy:1.0
                                                     verticalAccuracy:3.0
                                                            timestamp:[NSDate date]];
        [[theValue([AMPLocationUtils isRelevantLocation:location
                                             minRecency:10.0
                                            minAccurary:10.0]) should] beYes];
    });

    it(@"Should return NO for nil location", ^{
        [[theValue([AMPLocationUtils isRelevantLocation:nil
                                             minRecency:10.0
                                            minAccurary:10.0]) should] beNo];
    });

    it(@"Should return NO for old location", ^{
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(53.891059, 27.526119)
                                                             altitude:295.0
                                                   horizontalAccuracy:1.0
                                                     verticalAccuracy:3.0
                                                            timestamp:[NSDate dateWithTimeIntervalSinceNow:-20.0]];
        [[theValue([AMPLocationUtils isRelevantLocation:nil
                                             minRecency:10.0
                                            minAccurary:10.0]) should] beNo];
    });

    it(@"Should return NO for inaccurate horisontal location", ^{
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(53.891059, 27.526119)
                                                             altitude:295.0
                                                   horizontalAccuracy:11.0
                                                     verticalAccuracy:3.0
                                                            timestamp:[NSDate date]];
        [[theValue([AMPLocationUtils isRelevantLocation:nil
                                             minRecency:10.0
                                            minAccurary:10.0]) should] beNo];
    });

    it(@"Should return NO for inaccurate vertical location", ^{
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(53.891059, 27.526119)
                                                             altitude:295.0
                                                   horizontalAccuracy:1.0
                                                     verticalAccuracy:30.0
                                                            timestamp:[NSDate date]];
        [[theValue([AMPLocationUtils isRelevantLocation:nil
                                             minRecency:10.0
                                            minAccurary:10.0]) should] beNo];
    });
});

SPEC_END
