
#import "AMPEventsController.h"

#import "AMPLibraryAnalyticsTracker.h"
#import "AMPEnvironmentProvider.h"
#import "AMPEventsReporter.h"
#import "AMPTokenEventValueSerializer.h"
#import "AMPPushNotificationPayload.h"
#import "AMPPushNotificationPayloadParser.h"

NSString *const kAMPEventsControllerActionTypeReceive = @"receive";
NSString *const kAMPEventsControllerActionTypeOpen = @"open";
NSString *const kAMPEventsControllerActionTypeDismiss = @"dismiss";
NSString *const kAMPEventsControllerActionTypeCustom = @"custom";
NSString *const kAMPEventsControllerActionTypeProcessed = @"processed";
NSString *const kAMPEventsControllerActionTypeShown = @"shown";
NSString *const kAMPEventsControllerActionTypeIgnored = @"ignored";
NSString *const kAMPEventsControllerActionTypeRemoved = @"removed";

static NSString *const kAMPNotificationIDKey = @"notification_id";
static NSString *const kAMPNotificationActionKey = @"action";
static NSString *const kAMPNotificationActionTypeKey = @"type";
static NSString *const kAMPNotificationActionIDKey = @"id";
static NSString *const kAMPNotificationActionUri = @"uri";

@interface AMPEventsController ()

@property (nonatomic, strong) AMPEventsReporter *reporter;
@property (nonatomic, strong) AMPEnvironmentProvider *environmentProvider;
@property (nonatomic, strong) AMPLibraryAnalyticsTracker *libraryAnalyticsTracker;

@end

@implementation AMPEventsController

- (instancetype)init
{
    return [self initWithReporter:[[AMPEventsReporter alloc] init]
              environmentProvider:[[AMPEnvironmentProvider alloc] init]
          libraryAnalyticsTracker:[AMPLibraryAnalyticsTracker sharedInstance]];
}

- (instancetype)initWithReporter:(AMPEventsReporter *)reporter
             environmentProvider:(AMPEnvironmentProvider *)environmentProvider
         libraryAnalyticsTracker:(AMPLibraryAnalyticsTracker *)libraryAnalyticsTracker
{
    self = [super init];
    if (self != nil) {
        _environmentProvider = environmentProvider;
        _reporter = reporter;
        _libraryAnalyticsTracker = libraryAnalyticsTracker;
    }
    return self;
}

- (void)reportDeviceTokenWithModel:(AMPTokenEvent *)tokenModel
                   pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment
                         onFailure:(void (^)(NSError *error))onFailure
{
    [self.libraryAnalyticsTracker resumeSession];

    NSString *eventValue = [AMPTokenEventValueSerializer dataWithTokenEvent:tokenModel];
    NSDictionary *environment = [self.environmentProvider tokenEventEnvironmentForPushEnvironment:pushEnvironment];

    __weak __typeof(self) weakSelf = self;
    [self.reporter reportDeviceTokenWithValue:eventValue environment:environment onFailure:^(NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.reporter isReporterNotActivatedError:error]) {
            [AMPEventsController raiseReporterNotActivatedException];
        }
        [strongSelf.libraryAnalyticsTracker reportMetricaSendingEventError:error];

        if (onFailure != nil) {
            onFailure(error);
        }
    }];
}

- (void)reportPushNotificationWithNotificationID:(NSString *)notificationID
                                      actionType:(NSString *)actionType
                                        actionID:(NSString *)actionID
                                             uri:(NSString*)uri
                                       onFailure:(void (^)(NSError *error))onFailure
{
    if (notificationID.length == 0) {
        [self.libraryAnalyticsTracker reportInvalidNotification:nil withReason:@"no_notification_id"];
        return;
    }

    NSMutableDictionary *eventValue = [NSMutableDictionary dictionary];
    eventValue[kAMPNotificationIDKey] = notificationID;

    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    action[kAMPNotificationActionTypeKey] = actionType;
    action[kAMPNotificationActionIDKey] = actionID;
    if ([uri length] > 0) {
        action[kAMPNotificationActionUri] = uri;
    }
    eventValue[kAMPNotificationActionKey] = [action copy];

    NSDictionary *environment = [self.environmentProvider notificationEventEnvironment];

    __weak __typeof(self) weakSelf = self;
    [self.reporter reportPushNotification:eventValue environment:environment onFailure:^(NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.reporter isReporterNotActivatedError:error]) {
            [strongSelf.libraryAnalyticsTracker reportMetricaNotActivatedForAction:@"report_push_notification"];
        }
        [strongSelf.libraryAnalyticsTracker reportMetricaSendingEventError:error];

        if (onFailure != nil) {
            onFailure(error);
        }
    }];
}

- (void)sendEventsBuffer
{
    [self.reporter sendEventsBuffer];
}

+ (void)raiseReporterNotActivatedException
{
    [NSException raise:@"AppMetrica is not activated"
                format:@"AppMetrica hasn't been initialized yet."];
}

+ (instancetype)sharedInstance
{
    static AMPEventsController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[AMPEventsController alloc] init];
    });
    return controller;
}

@end
