
#import <Kiwi/Kiwi.h>

#import "AMPLibraryAnalyticsEnvironmentProvider.h"

SPEC_BEGIN(AMPLibraryAnalyticsEnvironmentProviderTests)

describe(@"AMPLibraryAnalyticsEnvironmentProvider", ^{

    let(environmentProvider, ^id{
        return [[AMPLibraryAnalyticsEnvironmentProvider alloc] init];
    });

    it(@"Should return common environment with app bundle identifier", ^{
        NSString *bundleID = @"BUNDLE";
        NSBundle *mainBundleMock = [NSBundle nullMock];
        [mainBundleMock stub:@selector(bundleIdentifier) andReturn:bundleID];
        [NSBundle stub:@selector(mainBundle) andReturn:mainBundleMock];

        NSDictionary *environment = [environmentProvider commonEnvironment];
        [[environment[@"app_id"] should] equal:bundleID];
    });

    it(@"Should return common environment with 'unknown' as app bundle identifier if not available", ^{
        NSBundle *mainBundleMock = [NSBundle nullMock];
        [mainBundleMock stub:@selector(bundleIdentifier) andReturn:nil];
        [NSBundle stub:@selector(mainBundle) andReturn:mainBundleMock];

        NSDictionary *environment = [environmentProvider commonEnvironment];
        [[environment[@"app_id"] should] equal:@"unknown"];
    });
    
});

SPEC_END
