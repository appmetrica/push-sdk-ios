
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AMPLazyPushProcessor.h"
#import "AMPLocationProvider.h"
#import "AMPPushNotificationController.h"
#import "AMPPushNotificationPayload.h"
#import "AMPLazyPayload.h"
#import "AMPLazyNetworkHelper.h"
#import "AMPLazyNotificationContentMerger.h"
#import "AMPLazyPayloadDefaultsHelper.h"
#import <UserNotifications/UserNotifications.h>
#import "AMPLazyPushProvider.h"

@interface AMPLazyPushProcessor ()

@property (nonatomic, strong, readonly) AMPLocationProvider *locationProvider;

@end

@implementation AMPLazyPushProcessor

+ (void)load
{
    [[AMPLazyPushProvider sharedInstance] setupPushProvider:[AMPLazyPushProcessor sharedInstance]];
}

+ (instancetype)sharedInstance
{
    static AMPLazyPushProcessor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AMPLazyPushProcessor alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    return [self initWithLocationProvider:[AMPLocationProvider sharedInstance]];
}

- (instancetype)initWithLocationProvider:(AMPLocationProvider *)locationProvider
{
    self = [super init];
    if (self != nil) {
        _locationProvider = locationProvider;
    }
    return self;
}

- (void)processNotificationContent:(UNNotificationContent *)content
                 withResultHandler:(AMPPushProcessorCallback)resultHandler
{
    [[AMPPushNotificationController sharedInstance] handleNotificationContent:content
                                                            withResultHandler:resultHandler];
}

- (void)processNotificationContent:(UNNotificationContent *)content
                       withPayload:(AMPPushNotificationPayload *)payload
                     resultHandler:(AMPPushProcessorCallback)resultHandler
{
    if (resultHandler == nil) {
        return;
    }
    AMPLazyPayload *lazyPayload = payload.lazy;
    if (lazyPayload != nil) {
        CLLocation *location = [self.locationProvider locationWithMinRecency:[AMPLazyPayloadDefaultsHelper minRecency:lazyPayload]
                                                                 minAccurary:[AMPLazyPayloadDefaultsHelper minAccuracy:lazyPayload]];
        if (location == nil) {
            resultHandler(content, nil);
            return;
        }
        NSString *url = [self urlWithNotificationPayload:payload
                                             lazyPayload:lazyPayload
                                                location:location];
        NSDictionary *headers = [self headersWithNotificationPayload:payload
                                                         lazyPayload:lazyPayload
                                                            location:location];
        AMPNetworkHelperResultHandler networkResultHandler = ^(NSDictionary *dictionary, NSError *error) {
            if (resultHandler == nil) {
                return;
            }
            if (error == nil) {
                UNNotificationContent *updatedContent = [AMPLazyNotificationContentMerger mergeNotificationContent:content
                                                                                                     andDictionary:dictionary];
                resultHandler(updatedContent, nil);
            }
            else {
                resultHandler(content, nil);
            }
        };
        [AMPLazyNetworkHelper makeGETRequestWithURL:url
                                            headers:headers
                                      resultHandler:networkResultHandler];
    }
    else {
        resultHandler(content, nil);
    }
}

- (NSString *)urlWithNotificationPayload:(AMPPushNotificationPayload *)payload
                             lazyPayload:(AMPLazyPayload *)lazyPayload
                                location:(CLLocation *)location
{
    return [self replacePattern:lazyPayload.url
        withNotificationPayload:payload
                       location:location];
}

- (NSDictionary *)headersWithNotificationPayload:(AMPPushNotificationPayload *)payload
                                     lazyPayload:(AMPLazyPayload *)lazyPayload
                                        location:(CLLocation *)location
{
    NSMutableDictionary *result = [lazyPayload.headers mutableCopy];
    for (NSString *key in result) {
        result[key] = [self replacePattern:result[key]
                   withNotificationPayload:payload
                                  location:location];
    }
    return result;
}

- (NSString *)replacePattern:(NSString *)value
     withNotificationPayload:(AMPPushNotificationPayload *)payload
                    location:(CLLocation *)location
{
    NSString *newValue = [value stringByReplacingOccurrencesOfString:@"{pushId}"
                                                     withString:payload.notificationID];
    newValue = [newValue stringByReplacingOccurrencesOfString:@"{lat}"
                                                   withString:[@(location.coordinate.latitude) stringValue]];
    newValue = [newValue stringByReplacingOccurrencesOfString:@"{lon}"
                                                   withString:[@(location.coordinate.longitude) stringValue]];
    return newValue;
}

@end
