
#import "AMPLazyNetworkHelper.h"
#import <AppMetricaPush/AppMetricaPush.h>


@implementation AMPLazyNetworkHelper

+ (void)makeGETRequestWithURL:(NSString *)url
                      headers:(NSDictionary *)headers
                resultHandler:(AMPNetworkHelperResultHandler)resultHandler {
    NSMutableURLRequest *request = [self requestWithUrl:url
                                                headers:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (resultHandler == nil) {
            return;
        }
        if (error != nil) {
            resultHandler(nil, error);
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"HTTP response status is not 200.",
                    @"NSHTTPURLResponseStatusCode": @(httpResponse.statusCode),
            };
            resultHandler(nil, [NSError errorWithDomain:NSURLErrorDomain
                                                   code:AMPErrorWrongStatusCode
                                               userInfo:userInfo]);
            return;
        }

        NSError *jsonError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&jsonError];
        if (jsonError != nil) {
            NSMutableDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"error when parsing json",
            }.mutableCopy;
            if (jsonError != nil) {
                userInfo[NSUnderlyingErrorKey] = jsonError;
            }
            resultHandler(nil, [NSError errorWithDomain:kAMPAppMetricaPushErrorDomain
                                                   code:AMPErrorParsingJson
                                               userInfo:userInfo]);
            return;
        }
        if ([object isKindOfClass:[NSDictionary class]]) {
            resultHandler(object, nil);
        }
        else {
            NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"not a dictionary",
            };
            resultHandler(nil, [NSError errorWithDomain:kAMPAppMetricaPushErrorDomain
                                                   code:AMPErrorJsonIsNotDictionary
                                               userInfo:userInfo]);
        }
    }] resume];
}

+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url
                                headers:(NSDictionary *)headers
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    for (NSString *key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end
