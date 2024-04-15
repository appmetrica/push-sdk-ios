
#import "AMPLibraryAnalyticsTracker.h"
#import "AMPLibraryAnalyticsEnvironmentProvider.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreExtension/AppMetricaCoreExtension.h>

static NSString *const kAMPReporterAPIKey = @"0e5e9c33-f8c3-4568-86c5-2e4f57523f72";

@interface AMPLibraryAnalyticsTracker ()

@property (nonatomic, strong, readonly) AMPLibraryAnalyticsEnvironmentProvider *environmentProvider;

@end

@implementation AMPLibraryAnalyticsTracker

- (instancetype)init
{
    return [self initWithEnvironmentProvider:[[AMPLibraryAnalyticsEnvironmentProvider alloc] init]];
}

- (instancetype)initWithEnvironmentProvider:(AMPLibraryAnalyticsEnvironmentProvider *)provider
{
    self = [super init];
    if (self != nil) {
        _environmentProvider = provider;
    }
    return self;
}

- (void)reportInvalidNotification:(NSDictionary *)notification withReason:(NSString *)reason
{
    NSDictionary *JSONReadyNotification = nil;
    if ([NSJSONSerialization isValidJSONObject:notification]) {
        JSONReadyNotification = notification;
    }

    NSDictionary *parameters = @{
        @"reason" : (reason ?: @"unknown"),
        @"info" : (JSONReadyNotification ?: @{})
    };
    [self reportEventWithName:@"Notification info broken"
                   parameters:parameters];
}

- (void)reportMetricaNotActivatedForAction:(NSString *)action
{
    [self reportEventWithName:@"Push reported before metrica activation"
                   parameters:@{ @"action" : action ?: @"unknown" }];
}

- (void)reportMetricaSendingEventError:(NSError *)error
{
    NSDictionary *parameters = @{
        @"error_code" : @(error.code),
        @"error_domain" : (error.domain ?: @"unknown"),
        @"error_userinfo" : (error.userInfo ?: @{})
    };

    [self reportEventWithName:@"Push reported before metrica activation"
                   parameters:parameters];
}

- (void)reportAttachmentDownloadError:(NSError *)error stage:(NSString *)stage
{
    NSString *stageKey = stage ?: @"unknown";
    NSDictionary *parameters = @{
        stageKey : @{
            @"domain": error.domain ?: @"unknown",
            @"code": @(error.code),
            @"user_info": error.userInfo.description ?: @"",
        },
    };
    [self reportEventWithName:@"Attachment download error" parameters:parameters];
}

- (void)reportEventWithName:(NSString *)name parameters:(NSDictionary *)parameters
{
    NSDictionary *environmentParameters = [self.environmentProvider commonEnvironment];
    NSMutableDictionary *fullParameters = [NSMutableDictionary dictionary];
    [fullParameters addEntriesFromDictionary:environmentParameters];
    [fullParameters addEntriesFromDictionary:parameters];

    [[self reporter] reportEvent:name parameters:fullParameters onFailure:nil];
}

- (void)resumeSession
{
    [[self reporter] resumeSession];
}

- (id<AMAAppMetricaReporting>)reporter
{
    return [AMAAppMetrica extendedReporterForApiKey:kAMPReporterAPIKey];
}

+ (instancetype)sharedInstance
{
    static AMPLibraryAnalyticsTracker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AMPLibraryAnalyticsTracker alloc] init];
    });
    return instance;
}

@end
