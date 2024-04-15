
#import <Foundation/Foundation.h>

@class UNNotificationContent;

NS_ASSUME_NONNULL_BEGIN

typedef void (^AMPPushProcessorCallback)(UNNotificationContent * _Nullable content, NSError * _Nullable error);

@protocol AMPPushProcessor

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(nullable AMPPushProcessorCallback)resultHandler;

@end

NS_ASSUME_NONNULL_END
