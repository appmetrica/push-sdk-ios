
#import <Foundation/Foundation.h>

@interface AMPSubscribedNotification : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL enabled;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name enabled:(BOOL)enabled;

@end
