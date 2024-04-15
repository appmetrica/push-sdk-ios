
#import <Foundation/Foundation.h>

@interface AMPLibraryAnalyticsTracker: NSObject

- (void)reportInvalidNotification:(NSDictionary *)notification withReason:(NSString *)reason;
- (void)reportMetricaNotActivatedForAction:(NSString *)action;
- (void)reportMetricaSendingEventError:(NSError *)error;
- (void)reportAttachmentDownloadError:(NSError *)error stage:(NSString *)stage;

- (void)reportEventWithName:(NSString *)name parameters:(NSDictionary *)parameters;
- (void)resumeSession;

+ (instancetype)sharedInstance;

@end
