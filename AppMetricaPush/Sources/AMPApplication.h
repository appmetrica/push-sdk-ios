
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AMPApplication : NSObject

+ (UIApplicationState)applicationState;
+ (void)openURL:(NSURL*)url;
+ (void)retrieveNotificationSettingsTypesWithBlock:(void(^)(UIUserNotificationType notificationTypes))block;

@end
