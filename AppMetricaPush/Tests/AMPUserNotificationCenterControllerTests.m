
#import <Kiwi/Kiwi.h>

#import "AMPUserNotificationCenterController.h"
#import "AMPUserNotificationCenterControllerMock.h"
#import "AMPUserNotificationCenterHandler.h"

SPEC_BEGIN(AMPUserNotificationCenterControllerTests)

describe(@"AMPUserNotificationCenterController", ^{

    AMPUserNotificationCenterController * __block controller = nil;
    AMPUserNotificationCenterHandler * __block handler = nil;

    UNUserNotificationCenter * __block center = nil;

    UNNotificationPresentationOptions const allPresentationOptions = (UNNotificationPresentationOptionAlert
                                                                      | UNNotificationPresentationOptionBadge
                                                                      | UNNotificationPresentationOptionSound
                                                                      );

    beforeEach(^{
        center = [UNUserNotificationCenter nullMock];

        handler = [AMPUserNotificationCenterHandler nullMock];
        controller = [[AMPUserNotificationCenterController alloc] initWithHandler:handler];
    });

    it(@"Should init with valid presentation options", ^{
        [[theValue(controller.presentationOptions) should] equal:theValue(allPresentationOptions)];
    });

    context(@"Will present notification", ^{

        UNNotification * __block notification = nil;
        SEL const selector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);

        beforeEach(^{
            notification = [UNNotification nullMock];
        });

        it(@"Should respond to selector", ^{
            BOOL doesRespond = [controller respondsToSelector:selector];
            [[theValue(doesRespond) should] beYes];
        });

        context(@"Without next delegate", ^{

            it(@"Should call callback", ^{
                BOOL __block wasCalled = NO;
                [controller userNotificationCenter:center
                           willPresentNotification:notification
                             withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                 wasCalled = YES;
                             }];
                [[theValue(wasCalled) should] beYes];
            });

            it(@"Should pass presentation options in callback", ^{
                UNNotificationPresentationOptions __block passedOptions = UNNotificationPresentationOptionNone;
                [controller userNotificationCenter:center
                           willPresentNotification:notification
                             withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                 passedOptions = options;
                             }];

                [[theValue(passedOptions) should] equal:theValue(allPresentationOptions)];
            });

        });

        context(@"With next delegate", ^{

            id<UNUserNotificationCenterDelegate> __block nextDelegate = nil;

            beforeEach(^{
                nextDelegate = [KWMock nullMockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                controller.nextDelegate = nextDelegate;
            });

            it(@"Should call next delegate", ^{
                void (^callback)(UNNotificationPresentationOptions) = ^(UNNotificationPresentationOptions options) { };
                [[(id)nextDelegate should] receive:selector withArguments:center, notification, callback];
                [controller userNotificationCenter:center
                           willPresentNotification:notification
                             withCompletionHandler:callback];
            });

            it(@"Should not call callback", ^{
                BOOL __block wasCalled = NO;
                [controller userNotificationCenter:center
                           willPresentNotification:notification
                             withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                 wasCalled = YES;
                             }];
                [[theValue(wasCalled) should] beNo];
            });

            context(@"Method not implemented", ^{

                beforeEach(^{
                    nextDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                });

                it(@"Should not call next delegate", ^{
                    void (^callback)(UNNotificationPresentationOptions) = ^(UNNotificationPresentationOptions options) { };
                    [[(id)nextDelegate shouldNot] receive:selector];
                    [controller userNotificationCenter:center
                               willPresentNotification:notification
                                 withCompletionHandler:callback];
                });

                it(@"Should call callback", ^{
                    BOOL __block wasCalled = NO;
                    [controller userNotificationCenter:center
                               willPresentNotification:notification
                                 withCompletionHandler:^(UNNotificationPresentationOptions options) {
                                     wasCalled = YES;
                                 }];
                    [[theValue(wasCalled) should] beYes];
                });

            });

        });

    });

    context(@"Did receive notification response", ^{

        UNNotificationResponse * __block notificationResponse = nil;
        SEL const selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);

        it(@"Should respond to selector", ^{
            notificationResponse = [UNNotificationResponse nullMock];

            BOOL doesRespond = [controller respondsToSelector:selector];
            [[theValue(doesRespond) should] beYes];
        });

        it(@"Should handle notification", ^{
            notificationResponse = [UNNotificationResponse nullMock];
            [notificationResponse stub:@selector(actionIdentifier) andReturn:UNNotificationDismissActionIdentifier];
            [[handler should] receive:@selector(userNotificationCenterDidReceiveNotificationResponse:)];
            [controller userNotificationCenter:center didReceiveNotificationResponse:notificationResponse withCompletionHandler:^{}];
        });

        context(@"Without next delegate", ^{

            it(@"Should call callback", ^{
                BOOL __block wasCalled = NO;
                [controller userNotificationCenter:center
                    didReceiveNotificationResponse:notificationResponse
                             withCompletionHandler:^{
                                 wasCalled = YES;
                             }];
                [[theValue(wasCalled) should] beYes];
            });

        });

        context(@"With next delegate", ^{

            AMPUserNotificationCenterDelegateMock *__block nextDelegate = nil;

            beforeEach(^{
                nextDelegate = [[AMPUserNotificationCenterDelegateMock alloc] init];
                controller.nextDelegate = nextDelegate;
            });

            it(@"Should call next delegate", ^{
                dispatch_block_t callback = ^{ };
                [[nextDelegate should] receive:selector withArguments:center, notificationResponse, callback];
                [controller userNotificationCenter:center
                    didReceiveNotificationResponse:notificationResponse
                             withCompletionHandler:callback];
            });

            it(@"Should not call callback", ^{
                BOOL __block wasCalled = NO;
                [controller userNotificationCenter:center
                    didReceiveNotificationResponse:notificationResponse
                             withCompletionHandler:^{
                                 wasCalled = YES;
                             }];
                [[theValue(wasCalled) should] beNo];
            });

            context(@"Method not implemented", ^{

                beforeEach(^{
                    nextDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                });

                it(@"Should not call next delegate", ^{
                    dispatch_block_t callback = ^{ };
                    [[nextDelegate shouldNot] receive:selector];
                    [controller userNotificationCenter:center
                        didReceiveNotificationResponse:notificationResponse
                                 withCompletionHandler:callback];
                });

                it(@"Should call callback", ^{
                    BOOL __block wasCalled = NO;
                    [controller userNotificationCenter:center
                        didReceiveNotificationResponse:notificationResponse
                                 withCompletionHandler:^{
                                     wasCalled = YES;
                                 }];
                    [[theValue(wasCalled) should] beYes];
                });

            });

        });
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma GCC diagnostic ignored "-Wundeclared-selector"

        context(@"Open settings for notification", ^{
            
            UNNotification * __block notification = nil;
            SEL const selector = @selector(userNotificationCenter:openSettingsForNotification:);

            beforeEach(^{
                notification = [UNNotification nullMock];
            });
            
            it(@"Should respond to selector", ^{
                BOOL doesRespond = [controller respondsToSelector:selector];
                [[theValue(doesRespond) should] beYes];
            });
            
            context(@"With next delegate", ^{
                
                AMPUserNotificationCenterDelegateMock *__block nextDelegate = nil;
                
                beforeEach(^{
                    nextDelegate = [[AMPUserNotificationCenterDelegateMock alloc] init];
                    controller.nextDelegate = nextDelegate;
                });
                
                it(@"Should call next delegate", ^{
                    [[nextDelegate should] receive:selector withArguments:center, notification];
                    [controller performSelector:selector withObject:center withObject:notification];
                });
                
                context(@"Method not implemented", ^{
                    
                    beforeEach(^{
                        nextDelegate = [KWMock mockForProtocol:@protocol(UNUserNotificationCenterDelegate)];
                    });
                    
                    it(@"Should not call next delegate", ^{
                        [[(id)nextDelegate shouldNot] receive:selector];
                        [controller performSelector:selector withObject:center withObject:notification];
                    });
                    
                });
                
            });

#pragma clang diagnostic pop

        });
    });

});

SPEC_END

