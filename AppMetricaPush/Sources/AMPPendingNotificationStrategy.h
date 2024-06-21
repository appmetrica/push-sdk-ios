
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AMPPendingNotificationStrategy;
@protocol AMACancelableExecuting;

@protocol AMPPendingNotificationStrategyDelegate<NSObject>
- (void)pendingNotificationStrategyDidRequestPush:(AMPPendingNotificationStrategy *)strategy;
@end

@interface AMPPendingNotificationStrategy : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithExecutor:(id<AMACancelableExecuting>)executor;

@property (nonatomic, strong, readonly) id<AMACancelableExecuting> executor;
@property (nonatomic, weak, nullable) id<AMPPendingNotificationStrategyDelegate> delegate;

@property (nonatomic, readwrite) NSTimeInterval maxInterval;
@property (nonatomic, readwrite) NSUInteger maxPendingPushes;

- (void)handlePushNotification;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
