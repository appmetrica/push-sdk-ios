#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (EncodingCharactersInit)

+ (nullable instancetype)URLWithEncodingCharactersString:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
