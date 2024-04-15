
#import "AMPEventsReporter.h"

#import "AMPLibraryAnalyticsTracker.h"
#import "AMPEventsReporterBridge.h"

#import <AppMetricaCore/AppMetricaCore.h>
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>

typedef NS_ENUM(NSUInteger, AMPEventType) {
    AMPEventTypePushToken = 14,
    AMPEventTypeNotification = 15,
};

static NSString *const kAMPEventNamePushToken = @"push_token";
static NSString *const kAMPEventNameNotification = @"push_notification";

@interface AMPEventsReporter ()

@property (nonatomic, strong) AMPEventsReporterBridge *bridge;

@end

@implementation AMPEventsReporter

- (instancetype)init
{
    return [self initWithEventsReporterBridge:[[AMPEventsReporterBridge alloc] init]];
}

- (instancetype)initWithEventsReporterBridge:(AMPEventsReporterBridge *)bridge
{
    self = [super init];
    if (self != nil) {
        _bridge = bridge;
    }
    return self;
}

- (void)reportDeviceTokenWithValue:(NSString *)eventValue
                       environment:(NSDictionary *)environment
                         onFailure:(void (^)(NSError *))onFailure
{
    [self.bridge reportEventWithType:AMPEventTypePushToken
                                name:kAMPEventNamePushToken
                               value:eventValue
                         environment:environment
                           onFailure:^(NSError *error) {
                               if (onFailure != nil) {
                                   onFailure([[self class] nonnilErrorForError:error]);
                               }
                           }];

    [AMAAppMetrica sendEventsBuffer];
}

- (void)reportPushNotification:(NSDictionary *)notification
                   environment:(NSDictionary *)environment
                     onFailure:(void (^)(NSError *))onFailure
{
    if ([NSJSONSerialization isValidJSONObject:notification] == NO) {
        // TODO(https://nda.ya.ru/t/uZ1x3MOo754PDG): Call onFailure.
        [[AMPLibraryAnalyticsTracker sharedInstance] reportInvalidNotification:notification
                                                                    withReason:@"invalid_json_object"];
        return;
    }

    NSData *notificationJSONData = [NSJSONSerialization dataWithJSONObject:notification options:0 error:nil];
    NSString *notificationJSONString = [[NSString alloc] initWithData:notificationJSONData
                                                             encoding:NSUTF8StringEncoding];

    // TODO(https://nda.ya.ru/t/uZ1x3MOo754PDG): Process JSON serialization error.
    [self.bridge reportEventWithType:AMPEventTypeNotification
                                name:kAMPEventNameNotification
                               value:notificationJSONString
                         environment:environment
                           onFailure:^(NSError *error) {
                               if (onFailure != nil) {
                                   onFailure([[self class] nonnilErrorForError:error]);
                               }
                           }];

    [AMAAppMetrica sendEventsBuffer];
}

- (void)sendEventsBuffer
{
    [AMAAppMetrica sendEventsBuffer];
}

+ (NSError *)nonnilErrorForError:(NSError *)error
{
    NSError *nonnilError = error;
    if (nonnilError == nil) {
        // TODO(https://nda.ya.ru/t/uZ1x3MOo754PDG): Fallback while AppMetrica could call onFailure with nil error: https://nda.ya.ru/t/KW-SvXRA754PEJ
        nonnilError = [AMAErrorUtilities errorWithCode:-1 description:nil];
    }
    return nonnilError;
}

- (BOOL)isReporterNotActivatedError:(NSError *)error
{
    if (error == nil) {
        return NO;
    }

    BOOL codeEquals = error.code == AMAAppMetricaEventErrorCodeInitializationError;
    return codeEquals && [error.domain isEqualToString:kAMAAppMetricaErrorDomain];
}

@end
