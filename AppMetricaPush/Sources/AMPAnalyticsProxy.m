#import "AMPAnalyticsProxy.h"

@import AppMetricaLibraryAdapter;

@interface AMPAnalyticsProxy ()

@property (nonatomic, assign) BOOL isActivateCalled;

@end

@implementation AMPAnalyticsProxy

+ (instancetype)sharedInstance
{
    static AMPAnalyticsProxy *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)activate
{
    @synchronized (self) {
        if (self.isActivateCalled == YES) {
            return;
        }
        
        [AMAAnalyticsLibraryAdapter.sharedInstance activate];
        self.isActivateCalled = YES;
    }
}

@end
