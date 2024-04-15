
#import "AMPAttachmentPayload.h"

@implementation AMPAttachmentPayload

- (instancetype)initWithIdentifier:(NSString *)identifier url:(NSURL *)url fileUTI:(NSString *)fileUTI
{
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _url = [url copy];
        _fileUTI = [fileUTI copy];
    }
    return self;
}

@end
