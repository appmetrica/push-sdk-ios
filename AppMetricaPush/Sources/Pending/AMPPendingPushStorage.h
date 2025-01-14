
#import <Foundation/Foundation.h>

@class AMPPendingPush;

@interface AMPPendingPushStorage : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)addPendingPush:(AMPPendingPush *)push;
- (NSArray<AMPPendingPush *> *)pendingPushes;
- (void)cleanup;

@end
