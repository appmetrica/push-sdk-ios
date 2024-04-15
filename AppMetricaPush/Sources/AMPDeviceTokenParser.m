
#import "AMPDeviceTokenParser.h"

@implementation AMPDeviceTokenParser

- (NSString *)deviceTokenFromData:(NSData *)data
{
    if (data.length == 0) {
        return nil;
    }

    const char *bytes = [data bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [data length]; i++) {
        [token appendFormat:@"%02.2hhX", bytes[i]];
    }

    return token;
}

@end
