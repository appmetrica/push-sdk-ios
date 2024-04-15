
#import <Foundation/Foundation.h>

@class AMPPendingPushController;
@class AMPPendingPush;

@protocol AMPPendingPushControllerDelegate <NSObject>

- (void)pendingPushController:(AMPPendingPushController *)controller didNotifyPendingPush:(AMPPendingPush *)push;

@end

@interface AMPPendingPushController : NSObject

@property (nonatomic, weak) id<AMPPendingPushControllerDelegate> delegate;

- (void)updateExtensionAppGroup:(NSString *)appGroup;
- (void)handlePendingPushReceivingWithNotificationID:(NSString *)notificationID;
- (void)notifyAboutPendingPushes;

@end
