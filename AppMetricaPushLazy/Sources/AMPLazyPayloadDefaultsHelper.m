
#import "AMPLazyPayloadDefaultsHelper.h"
#import "AMPLazyPayload.h"
#import "AMPLazyLocationPayload.h"


static double const kAMPDefaultMinRecency = 300;
static double const kAMPDefaultMinAccuracy = 500;

@implementation AMPLazyPayloadDefaultsHelper

+ (double)minRecency:(AMPLazyPayload *)lazyPayload
{
    if (lazyPayload.location.minRecency != nil) {
        return lazyPayload.location.minRecency.doubleValue;
    }
    else {
        return kAMPDefaultMinRecency;
    }
}

+ (double)minAccuracy:(AMPLazyPayload *)lazyPayload
{
    if (lazyPayload.location.minAccuracy != nil) {
        return lazyPayload.location.minAccuracy.doubleValue;
    }
    else {
        return kAMPDefaultMinAccuracy;
    }
}

@end
