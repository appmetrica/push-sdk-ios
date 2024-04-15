
#import <Foundation/Foundation.h>

@interface AMPPendingPush : NSObject

@property (nonatomic, copy, readonly) NSString *notificationID;
@property (nonatomic, copy, readonly) NSDate *receivingDate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNotificationID:(NSString *)notificationID receivingDate:(NSDate *)receivingDate;

@end
