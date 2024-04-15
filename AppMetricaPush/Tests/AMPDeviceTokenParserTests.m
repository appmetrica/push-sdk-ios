
#import <Kiwi/Kiwi.h>

#import "AMPDeviceTokenParser.h"

SPEC_BEGIN(AMPDeviceTokenParserTests)

describe(@"AMPDeviceTokenParser", ^{

    let(parser, ^id{
        return [AMPDeviceTokenParser new];
    });

    NSData *(^dataFromHexString)(NSString *) = ^id(NSString *string) {
        NSMutableData* data = [NSMutableData data];
        for (NSUInteger idx = 0; idx + 2 <= string.length; idx += 2) {
            NSRange range = NSMakeRange(idx, 2);
            NSString* hexStr = [string substringWithRange:range];
            NSScanner* scanner = [NSScanner scannerWithString:hexStr];
            unsigned int intValue = 0;
            BOOL scanned = [scanner scanHexInt:&intValue];
            if (scanned == NO) {
                return nil;
            }
            [data appendBytes:&intValue length:1];
        }
        return data;
    };

    it(@"Should return nil on empty data", ^{
        NSString *token = [parser deviceTokenFromData:[NSData new]];
        [[token should] beNil];
    });

    it(@"Should return nil on nil data", ^{
        NSString *token = [parser deviceTokenFromData:nil];
        [[token should] beNil];
    });

    it(@"Should parse actual token", ^{
        NSString *hexToken = @"EE151C02A727181AA1AD0498CB46473EB6AA4D847873DD0850F341784D9028A3";
        NSData *tokenData = dataFromHexString(hexToken);
        NSString *token = [parser deviceTokenFromData:tokenData];
        [[token should] equal:hexToken];
    });

});

SPEC_END
