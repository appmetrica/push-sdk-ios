
#import <Kiwi/Kiwi.h>
#import <CoreLocation/CoreLocation.h>
#import "AMPLazyPayload.h"
#import "AMPLazyLocationPayload.h"
#import "AMPLazyPayloadDefaultsHelper.h"

SPEC_BEGIN(AMPLazyPayloadDefaultsHelperTests)

describe(@"AMPLazyPayloadDefaultsHelper", ^{

    it(@"Should return minRecency 300 if lazyPayload is nil", ^{
        double result = [AMPLazyPayloadDefaultsHelper minRecency:nil];
        [[theValue(result) should] equal:theValue(300)];
    });

    it(@"Should return minRecency 300 if lazyLocationPayload is nil", ^{
        AMPLazyPayload *lazyPayload = [[AMPLazyPayload alloc] initWithUrl:nil
                                                                  headers:nil
                                                                 location:nil];
        double result = [AMPLazyPayloadDefaultsHelper minRecency:lazyPayload];
        [[theValue(result) should] equal:theValue(300)];
    });

    it(@"Should return proper minRecency value if all is ok", ^{
        AMPLazyLocationPayload *lazyLocationPayload = [[AMPLazyLocationPayload alloc] initWithMinRecency:@10
                                                                                             minAccuracy:@11];
        AMPLazyPayload *lazyPayload = [[AMPLazyPayload alloc] initWithUrl:nil
                                                                  headers:nil
                                                                 location:lazyLocationPayload];
        double result = [AMPLazyPayloadDefaultsHelper minRecency:lazyPayload];
        [[theValue(result) should] equal:theValue(10)];
    });

    it(@"Should return minAccuracy 300 if lazyPayload is nil", ^{
        double result = [AMPLazyPayloadDefaultsHelper minAccuracy:nil];
        [[theValue(result) should] equal:theValue(500)];
    });

    it(@"Should return minAccuracy 300 if lazyLocationPayload is nil", ^{
        AMPLazyPayload *lazyPayload = [[AMPLazyPayload alloc] initWithUrl:nil
                                                                  headers:nil
                                                                 location:nil];
        double result = [AMPLazyPayloadDefaultsHelper minAccuracy:lazyPayload];
        [[theValue(result) should] equal:theValue(500)];
    });

    it(@"Should return proper minAccuracy value if all is ok", ^{
        AMPLazyLocationPayload *lazyLocationPayload = [[AMPLazyLocationPayload alloc] initWithMinRecency:@10
                                                                                             minAccuracy:@11];
        AMPLazyPayload *lazyPayload = [[AMPLazyPayload alloc] initWithUrl:nil
                                                                  headers:nil
                                                                 location:lazyLocationPayload];
        double result = [AMPLazyPayloadDefaultsHelper minAccuracy:lazyPayload];
        [[theValue(result) should] equal:theValue(11)];
    });
});

SPEC_END
