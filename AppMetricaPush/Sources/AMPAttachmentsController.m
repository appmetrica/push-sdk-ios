
#import "AMPAttachmentsController.h"
#import "AMPPushNotificationPayload.h"
#import "AMPPushNotificationPayloadParser.h"
#import "AMPAttachmentsLoader.h"

@interface AMPAttachmentsController ()

@property (nonatomic, strong, readonly) AMPPushNotificationPayloadParser *payloadParser;

@end

@implementation AMPAttachmentsController

- (instancetype)init
{
    return [self initWithPayloadParser:[[AMPPushNotificationPayloadParser alloc] init]];
}

- (instancetype)initWithPayloadParser:(AMPPushNotificationPayloadParser *)payloadParser
{
    self = [super init];
    if (self != nil) {
        _payloadParser = payloadParser;
    }
    return self;
}

- (void)downloadAttachmentsForUserInfo:(NSDictionary *)userInfo
                              callback:(AMPAttachmentsControllerCallback)callback
{
    AMPPushNotificationPayload *payload = [self.payloadParser pushNotificationPayloadFromDictionary:userInfo];
    AMPAttachmentsLoader *__block loader = [[AMPAttachmentsLoader alloc] initWithAttachments:payload.attachments];
    [loader downloadWithCallback:^(NSArray<UNNotificationAttachment *> *attachments, NSError *error) {
        loader = nil;
        if (callback != nil) {
            callback(attachments, error);
        }
    }];
}

+ (instancetype)sharedInstance
{
    static AMPAttachmentsController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AMPAttachmentsController alloc] init];
    });
    return instance;
}

@end
