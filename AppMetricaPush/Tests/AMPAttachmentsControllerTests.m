
#import <Kiwi/Kiwi.h>
#import "AMPAttachmentsController.h"
#import "AMPPushNotificationPayloadParser.h"
#import "AMPPushNotificationPayload.h"
#import "AMPAttachmentPayload.h"
#import "AMPAttachmentsLoader.h"
#import "AMPTestUtilities.h"

SPEC_BEGIN(AMPAttachmentsControllerTests)

describe(@"AMPAttachmentsController", ^{

    NSArray *const attachments = @[
        [AMPAttachmentPayload nullMock],
        [AMPAttachmentPayload nullMock]
    ];
    AMPPushNotificationPayload *const payload = [[AMPPushNotificationPayload alloc] initWithNotificationID:nil
                                                                                                 targetURL:nil
                                                                                                  userData:nil
                                                                                               attachments:attachments
                                                                                                    silent:NO
                                                                                            delCollapseIDs:@[]
                                                                                                      lazy:nil];
    NSDictionary *const userInfo = @{ @"foo": @"bar" };

    AMPPushNotificationPayloadParser *__block parser = nil;
    AMPAttachmentsLoader *__block loader = nil;
    AMPAttachmentsController *__block controller = nil;

    beforeEach(^{
        parser = [AMPPushNotificationPayloadParser nullMock];
        [parser stub:@selector(pushNotificationPayloadFromDictionary:) andReturn:payload];
        loader = [AMPAttachmentsLoader stubbedNullMockForInit:@selector(initWithAttachments:)];
        controller = [[AMPAttachmentsController alloc] initWithPayloadParser:parser];
    });

    it(@"Should parse user info", ^{
        [[parser should] receive:@selector(pushNotificationPayloadFromDictionary:) withArguments:userInfo];
        [controller downloadAttachmentsForUserInfo:userInfo callback:nil];
    });

    it(@"Should create loader", ^{
        [[loader should] receive:@selector(initWithAttachments:) withArguments:attachments];
        [controller downloadAttachmentsForUserInfo:userInfo callback:nil];
    });

    it(@"Should call callback from loader", ^{
        NSError *const expectedError = [NSError errorWithDomain:@"a" code:2 userInfo:@{ @"foo": @"bar" }];
        NSArray *const expectedAttachments = @[ @"foo", @"bar" ];

        AMPAttachmentsLoaderCallback __block loaderCallback = nil;
        [loader stub:@selector(downloadWithCallback:) withBlock:^id(NSArray *params) {
            loaderCallback = params[0];
            return nil;
        }];
        BOOL __block callbackCalled = NO;
        [controller downloadAttachmentsForUserInfo:userInfo callback:^(NSArray *attachments, NSError *error) {
            callbackCalled = YES;
            [[attachments should] equal:expectedAttachments];
            [[error should] equal:expectedError];
        }];
        [[loaderCallback shouldNot] beNil];
        loaderCallback(expectedAttachments, expectedError);
        [[theValue(callbackCalled) should] beYes];
    });

});

SPEC_END

