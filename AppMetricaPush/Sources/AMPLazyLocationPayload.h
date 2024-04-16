
#import <Foundation/Foundation.h>

@interface AMPLazyLocationPayload : NSObject

@property (nonatomic, strong, readonly) NSNumber *minRecency;
@property (nonatomic, strong, readonly) NSNumber *minAccuracy;

- (instancetype)initWithMinRecency:(NSNumber *)minRecency
                       minAccuracy:(NSNumber *)minAccuracy;

@end
