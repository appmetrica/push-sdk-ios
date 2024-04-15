
#import <Foundation/Foundation.h>

@class AMPLazyLocationPayload;


@interface AMPLazyPayload : NSObject

@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, strong, readonly) AMPLazyLocationPayload *location;

- (instancetype)initWithUrl:(NSString *)url
                    headers:(NSDictionary *)headers
                   location:(AMPLazyLocationPayload *)location;

@end
