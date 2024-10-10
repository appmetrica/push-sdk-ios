
#import <AppMetricaCoreUtils/AppMetricaCoreUtils.h>
#import "AMPPushNotificationPayloadParser.h"
#import "AMPPushNotificationPayload.h"
#import "AMPAttachmentPayload.h"
#import "AMPLazyPayload.h"
#import "AMPLazyLocationPayload.h"
#import "NSURL+EncodingCharactersInit.h"

@implementation AMPPushNotificationPayloadParser

- (AMPPushNotificationPayload *)pushNotificationPayloadFromDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }
    NSDictionary *domainDictionary = dictionary[@"yamp"];
    if ([domainDictionary isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }

    NSString *notificationID = domainDictionary[@"i"];
    NSString *targetURL = domainDictionary[@"l"];
    NSString *userData = domainDictionary[@"d"];
    NSArray *attachments = [self attachmentsForArray:domainDictionary[@"a"]];
    BOOL silent = NO;

    NSDictionary *apsDictionary = dictionary[@"aps"];
    if ([apsDictionary isKindOfClass:[NSDictionary class]]) {
        silent = [apsDictionary[@"content-available"] isEqual:@1];
    }
    
    NSArray<NSString *> *delCollapseIDs = domainDictionary[@"del-collapse-ids"];
    if ([delCollapseIDs isKindOfClass:[NSArray class]] == NO) {
        delCollapseIDs = @[];
    }
    NSArray<NSString *> *validCollapseIds = [AMACollectionUtilities filteredArray:delCollapseIDs
                                                                    withPredicate:^BOOL(id delCollapseId) {
        return (delCollapseId != nil) && [delCollapseId isKindOfClass:[NSString class]];
    }];

    AMPLazyPayload *lazyPayload = [self lazyPayloadForDict:domainDictionary[@"g"]];

    AMPPushNotificationPayload *parsedPayload =
        [[AMPPushNotificationPayload alloc] initWithNotificationID:notificationID
                                                         targetURL:targetURL
                                                          userData:userData
                                                       attachments:attachments
                                                            silent:silent
                                                    delCollapseIDs:validCollapseIds
                                                              lazy:lazyPayload];
    return parsedPayload;
}

- (NSArray *)attachmentsForArray:(NSArray *)attachmentsArray
{
    if ([attachmentsArray isKindOfClass:[NSArray class]] == NO) {
        return @[];
    }

    NSMutableArray *attachments = [NSMutableArray array];
    for (NSDictionary *attachmentDictionary in attachmentsArray) {
        if ([attachmentDictionary isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }

        NSString *identifier = attachmentDictionary[@"i"];
        NSString *urlString = attachmentDictionary[@"l"];
        if ([identifier isKindOfClass:[NSString class]] == NO || [urlString isKindOfClass:[NSString class]] == NO) {
            continue;
        }

        NSString *fileUTI = attachmentDictionary[@"t"];
        if (fileUTI != nil && [fileUTI isKindOfClass:[NSString class]] == NO) {
            continue;
        }
   
        NSURL *attachmentURL = [NSURL URLWithEncodingCharactersString:urlString];
        
        if (attachmentURL == nil) {
            continue;
        }

        AMPAttachmentPayload *attachment = [[AMPAttachmentPayload alloc] initWithIdentifier:identifier
                                                                                        url:attachmentURL
                                                                                    fileUTI:fileUTI];
        [attachments addObject:attachment];
    }

    return [attachments copy];
}

- (AMPLazyPayload *)lazyPayloadForDict:(NSDictionary *)payloadDict
{
    if ([payloadDict isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }

    NSString *url = payloadDict[@"a"];
    if ([url isKindOfClass:[NSString class]] == NO) {
        return nil;
    }

    NSDictionary *headers = payloadDict[@"c"];
    if (headers != nil && [headers isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }

    AMPLazyLocationPayload *lazyLocationPayload = [self lazyLocationPayloadForDict:payloadDict[@"d"]];

    AMPLazyPayload *lazyPayload = [[AMPLazyPayload alloc] initWithUrl:url
                                                              headers:headers
                                                             location:lazyLocationPayload];
    return lazyPayload;
}

- (AMPLazyLocationPayload *)lazyLocationPayloadForDict:(NSDictionary *)payloadDict
{
    if ([payloadDict isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }

    NSNumber *minRecency = payloadDict[@"c"];
    if (minRecency != nil && [minRecency isKindOfClass:[NSNumber class]] == NO) {
        return nil;
    }
    NSNumber *minAccuracy = payloadDict[@"d"];
    if (minAccuracy != nil && [minAccuracy isKindOfClass:[NSNumber class]] == NO) {
        return nil;
    }

    AMPLazyLocationPayload *lazyLocationPayload = [[AMPLazyLocationPayload alloc] initWithMinRecency:minRecency
                                                                                         minAccuracy:minAccuracy];
    return lazyLocationPayload;
}

@end
