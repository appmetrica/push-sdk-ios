
#import "AMPUserNotificationCenterController.h"
#import "AMPUserNotificationCenterHandler.h"

@interface AMPUserNotificationCenterController ()

@property (nonatomic, strong, readonly) AMPUserNotificationCenterHandler *handler;

@end

@implementation AMPUserNotificationCenterController

@synthesize nextDelegate = _nextDelegate;
@synthesize presentationOptions = _presentationOptions;

- (instancetype)init
{
    return [self initWithHandler:[AMPUserNotificationCenterHandler sharedInstance]];
}

- (instancetype)initWithHandler:(AMPUserNotificationCenterHandler *)handler
{
    self = [super init];
    if (self != nil) {
        _presentationOptions =
            UNNotificationPresentationOptionBadge |
            UNNotificationPresentationOptionSound |
            UNNotificationPresentationOptionAlert;
        _handler = handler;
    }
    return self;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [self.handler userNotificationCenterWillPresentNotification:notification];

    SEL selector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
    if ([self.nextDelegate respondsToSelector:selector]) {
        [self.nextDelegate userNotificationCenter:center
                          willPresentNotification:notification
                            withCompletionHandler:completionHandler];
    }
    else {
        if (completionHandler != nil) {
            completionHandler(self.presentationOptions);
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{

    [self.handler userNotificationCenterDidReceiveNotificationResponse:response];

    SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
    if ([self.nextDelegate respondsToSelector:selector]) {
        [self.nextDelegate userNotificationCenter:center
                   didReceiveNotificationResponse:response
                            withCompletionHandler:completionHandler];
    }
    else {
        if (completionHandler != nil) {
            completionHandler();
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
   openSettingsForNotification:(UNNotification *)notification
{
    [self.handler userNotificationCenterOpenSettingsForNotification:notification];

    SEL selector = @selector(userNotificationCenter:openSettingsForNotification:);
    if ([self.nextDelegate respondsToSelector:selector]) {
        [self.nextDelegate performSelector:selector withObject:center withObject:notification];
    }
}

#pragma clang diagnostic pop

+ (instancetype)sharedInstance
{
    static AMPUserNotificationCenterController *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[AMPUserNotificationCenterController alloc] init];
    });
    return delegate;
}

@end
