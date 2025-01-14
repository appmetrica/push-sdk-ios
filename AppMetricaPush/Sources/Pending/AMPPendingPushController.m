
#import "AMPPendingPushController.h"
#import "AMPPushNotificationPayload.h"
#import "AMPPendingPushSerializer.h"
#import "AMPPendingPush.h"
#import "AMPEventsController.h"
#import "AMPPendingPushStorage.h"

@interface AMPPendingPushController ()

@property (nonatomic, strong) AMPPendingPushStorage *storage;

@end

@implementation AMPPendingPushController

- (void)updateExtensionAppGroup:(NSString *)appGroup
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    @synchronized (self) {
        self.storage = [[AMPPendingPushStorage alloc] initWithUserDefaults:userDefaults];
    }
}

- (void)notifyAboutPendingPushes
{
    NSArray *pushes = nil;
    @synchronized (self) {
        pushes = [self.storage pendingPushes];
        [self.storage cleanup];
    }
    for (AMPPendingPush *push in pushes) {
        [self.delegate pendingPushController:self didNotifyPendingPush:push];
    }
}

@end
