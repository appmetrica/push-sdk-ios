
#import "AMPPushNotificationPayload.h"
#import "AMPLazyPayload.h"

@implementation AMPPushNotificationPayload

- (instancetype)initWithNotificationID:(NSString *)notificationID
                             targetURL:(NSString *)targetURL
                              userData:(NSString *)userData
                           attachments:(NSArray<AMPAttachmentPayload *> *)attachments
                                silent:(BOOL)silent
                                  lazy:(AMPLazyPayload *)lazy
{
    self = [super init];
    if (self != nil) {
        _notificationID = [notificationID copy];
        _targetURL = [targetURL copy];
        _userData = [userData copy];
        _attachments = [attachments copy];
        _silent = silent;
        _lazy = lazy;
    }
    return self;
}

@end
