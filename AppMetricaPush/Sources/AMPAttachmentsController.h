
#import <Foundation/Foundation.h>

@class AMPPushNotificationPayloadParser;

NS_ASSUME_NONNULL_BEGIN

typedef void (^AMPAttachmentsControllerCallback)( NSArray * _Nullable attachments,  NSError * _Nullable error);

@interface AMPAttachmentsController : NSObject

- (instancetype)initWithPayloadParser:(AMPPushNotificationPayloadParser *)payloadParser;

- (void)downloadAttachmentsForUserInfo:(NSDictionary *)userInfo
                              callback:(nullable AMPAttachmentsControllerCallback)callback;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
