
#import "AMPLazyPushProvider.h"

@interface AMPLazyPushProvider ()

@property (nonatomic, nullable, strong) id<AMPLazyPushProviding> provider;

@end

@implementation AMPLazyPushProvider

+ (instancetype)sharedInstance 
{
    static AMPLazyPushProvider *provider = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        provider = [[[self class] alloc] init];
    });
    
    return provider;
}

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(nullable AMPPushProcessorCallback)resultHandler 
{
    id<AMPLazyPushProviding> provider = self.provider;
    
    if (provider != nil) {
        [provider processNotificationContent:content
                           withResultHandler:resultHandler];
    } else if (resultHandler != nil) {
        resultHandler(content, nil);
    }
}

- (void)processNotificationContent:(UNNotificationContent *)content 
                       withPayload:(id)payload
                     resultHandler:(AMPPushProcessorCallback)resultHandler 
{
    id<AMPLazyPushProviding> provider = self.provider;
    
    if (provider != nil) {
        [provider processNotificationContent:content
                                 withPayload:payload
                               resultHandler:resultHandler];
    } else if (resultHandler != nil) {
        resultHandler(content, nil);
    }
}

- (void)setupPushProvider:(id<AMPLazyPushProviding>)provider 
{
    self.provider = provider;
}

@end
