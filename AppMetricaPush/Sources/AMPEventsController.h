
#import <Foundation/Foundation.h>
#import "AMPAppMetricaPushEnvironment.h"

extern NSString *const kAMPEventsControllerActionTypeReceive;
extern NSString *const kAMPEventsControllerActionTypeOpen;
extern NSString *const kAMPEventsControllerActionTypeDismiss;
extern NSString *const kAMPEventsControllerActionTypeCustom;
extern NSString *const kAMPEventsControllerActionTypeProcessed;
extern NSString *const kAMPEventsControllerActionTypeShown;
extern NSString *const kAMPEventsControllerActionTypeIgnored;
extern NSString *const kAMPEventsControllerActionTypeRemoved;

@class AMPEventsReporter;
@class AMPEnvironmentProvider;
@class AMPLibraryAnalyticsTracker;
@class AMPTokenEvent;

@interface AMPEventsController : NSObject

- (instancetype)initWithReporter:(AMPEventsReporter *)reporter
             environmentProvider:(AMPEnvironmentProvider *)environmentProvider
         libraryAnalyticsTracker:(AMPLibraryAnalyticsTracker *)libraryAnalyticsTracker;

- (void)reportDeviceTokenWithModel:(AMPTokenEvent *)tokenModel
                   pushEnvironment:(AMPAppMetricaPushEnvironment)pushEnvironment
                         onFailure:(void (^)(NSError *error))onFailure;

- (void)reportPushNotificationWithNotificationID:(NSString *)notificationID
                                      actionType:(NSString *)actionType
                                        actionID:(NSString *)actionID
                                       onFailure:(void (^)(NSError *error))onFailure;

- (void)sendEventsBuffer;

+ (instancetype)sharedInstance;

@end
