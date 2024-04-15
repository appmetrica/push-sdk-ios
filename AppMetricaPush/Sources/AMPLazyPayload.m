
#import "AMPLazyPayload.h"
#import "AMPLazyLocationPayload.h"


@implementation AMPLazyPayload

- (instancetype)initWithUrl:(NSString *)url
                    headers:(NSDictionary *)headers
                   location:(AMPLazyLocationPayload *)location {
    self = [super init];
    if (self != nil) {
        _url = [url copy];
        _headers = [headers copy];
        _location = location;
    }
    return self;
}

@end
