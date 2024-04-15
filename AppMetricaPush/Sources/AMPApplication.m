
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>
#import "AMPApplication.h"

@implementation AMPApplication

+ (UIApplicationState)applicationState
{
    return [self sharedApplication].applicationState;
}

+ (void)openURL:(NSURL*)URL
{
    [self executeWithBlock:^{
        UIApplication *application = [self sharedApplication];

        typedef void (*MethodType)(id, SEL, id, id, id);
        SEL openURLSelector = @selector(openURL:options:completionHandler:);
        MethodType openURLMethod = (MethodType)[application methodForSelector:openURLSelector];
        openURLMethod(application, openURLSelector, URL, @{}, nil);
    }];
}

+ (void)retrieveNotificationSettingsTypesWithBlock:(void(^)(UIUserNotificationType notificationTypes))block
{
    if (block != nil) {
        [self executeWithBlock:^{
            UIUserNotificationType types = [self sharedApplication].currentUserNotificationSettings.types;
            block(types);
        }];
    }
}

+ (UIApplication *)sharedApplication
{
    return [UIApplication performSelector:@selector(sharedApplication)];
}

+ (void)executeWithBlock:(dispatch_block_t)block
{
    if (block != nil) {
        [[self mainQueueExecutor] execute:block];
    }
}

+ (id<AMAAsyncExecuting>)mainQueueExecutor
{
    static id<AMAAsyncExecuting> executor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executor = [[AMAExecutor alloc] initWithQueue:dispatch_get_main_queue()];
    });
    return executor;
}

@end
