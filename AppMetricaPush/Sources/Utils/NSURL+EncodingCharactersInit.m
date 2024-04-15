#import "NSURL+EncodingCharactersInit.h"

@implementation NSURL (EncodingCharactersInit)

+ (nullable instancetype)URLWithEncodingCharactersString:(NSString *)URLString 
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_17
        if (@available(iOS 17.0, *)) {
            return [NSURL URLWithString:URLString encodingInvalidCharacters:NO];
        } else {
            return [NSURL URLWithString:URLString];
        }
#else
        return [NSURL URLWithString:urlString];
#endif
        
}

@end
