
#import <Foundation/Foundation.h>


typedef void (^AMPNetworkHelperResultHandler)(NSDictionary *, NSError *);
typedef NS_ENUM(NSInteger, AMPLazyNetworkHelperErrorCode) {
    AMPErrorWrongStatusCode,
    AMPErrorParsingJson,
    AMPErrorJsonIsNotDictionary,
};

@interface AMPLazyNetworkHelper : NSObject

+ (void)makeGETRequestWithURL:(NSString *)url
                      headers:(NSDictionary *)headers
                resultHandler:(AMPNetworkHelperResultHandler)resultHandler;

@end
