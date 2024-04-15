
#import <Foundation/Foundation.h>

@class AMPSubscribedNotification;

@interface AMPTokenEvent : NSObject

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, assign, readonly) BOOL enabled;
@property (nonatomic, copy) NSArray<AMPSubscribedNotification *> *notifications;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithToken:(NSString *)token
                      enabled:(BOOL)enabled
                notifications:(NSArray<AMPSubscribedNotification *> *)notifications;

@end
