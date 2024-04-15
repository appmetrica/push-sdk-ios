
#import <Foundation/Foundation.h>

@class AMPAttachmentPayload;
@class AMPLazyPayload;

@interface AMPPushNotificationPayload : NSObject

@property (nonatomic, copy, readonly) NSString *notificationID;
@property (nonatomic, copy, readonly) NSString *targetURL;
@property (nonatomic, copy, readonly) NSString *userData;
@property (nonatomic, copy, readonly) NSArray<AMPAttachmentPayload *> *attachments;
@property (nonatomic, assign, readonly) BOOL silent;
@property (nonatomic, strong, readonly) AMPLazyPayload *lazy;

- (instancetype)initWithNotificationID:(NSString *)notificationID
                             targetURL:(NSString *)targetURL
                              userData:(NSString *)userData
                           attachments:(NSArray<AMPAttachmentPayload *> *)attachments
                                silent:(BOOL)silent
                                  lazy:(AMPLazyPayload *)lazy;

@end
