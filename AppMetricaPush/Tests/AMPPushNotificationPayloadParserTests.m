
#import <Kiwi/Kiwi.h>
#import "AMPPushNotificationPayloadParser.h"
#import "AMPPushNotificationPayload.h"
#import "AMPAttachmentPayload.h"
#import "AMPLazyPayload.h"
#import "AMPLazyLocationPayload.h"

SPEC_BEGIN(AMPPushNotificationPayloadParserTests)

describe(@"AMPPushNotificationPayloadParser", ^{

    let(parser, ^id{
        return [AMPPushNotificationPayloadParser new];
    });

    it(@"Should return nil on nil dictionary", ^{
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:nil];
        [[payload should] beNil];
    });

    it(@"Should return nil on non dictionary object", ^{
        id someObject = @"not dictionary";
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:someObject];
        [[payload should] beNil];
    });

    it(@"Should return nil on empty dictionary", ^{
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:[NSDictionary dictionary]];
        [[payload should] beNil];
    });

    it(@"Should return nil on dictionary without SDK domain", ^{
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{} }];
        [[payload should] beNil];
    });

    it(@"Should return nil on dictionary with wrong object in domain", ^{
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{}, @"yamp" : @"wrong" }];
        [[payload should] beNil];
    });

    context(@"Actual payload", ^{

        NSString *const notificationID = @"NOTIFICATION_ID";
        NSString *const targetURL = @"TARGET_URL";
        NSString *const userData = @"USER_DATA";
        NSString *const attachmentID = @"ATTACHMENT_ID";
        NSString *const attachmentURL = @"https://attachment.url";
        NSString *const attachmentType = @"ATTACHMENT_TYPE";
        NSString *const lazyUrl = @"https://lazy.payload.url";
        NSString *const lazyHeaderKey = @"HEADER_KEY";
        NSString *const lazyHeaderValue = @"HEADER_VALUE";
        NSNumber *const lazyMinRecency = @4242;
        NSNumber *const lazyMinAccuracy = @42;
        NSDictionary *const payloadDictionary = @{
            @"aps" : @{
                @"alert" : @"Message",
                @"badge" : @0
            },
            @"yamp" : @{
                @"i" : notificationID,
                @"l" : targetURL,
                @"d" : userData,
                @"a" : @[
                    @{
                        @"i": attachmentID,
                        @"l": attachmentURL,
                        @"t": attachmentType,
                    },
                ],
                @"g" : @{
                    @"a" : lazyUrl,
                    @"c" : @{
                        lazyHeaderKey: lazyHeaderValue
                    },
                    @"d" : @{
                        @"c": lazyMinRecency,
                        @"d": lazyMinAccuracy
                    }
                },
                @"del-collapse-ids": @[
                    @"collapse-id-1",
                    @"collapse-id-2",
                    @YES,
                    @99,
                    @[],
                    [NSNull null],
                ],
            }
        };

        it(@"Should parse actual notification ID", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:payloadDictionary];
            [[payload.notificationID should] equal:notificationID];
        });

        it(@"Should parse actual target URL", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:payloadDictionary];
            [[payload.targetURL should] equal:targetURL];
        });

        it(@"Should parse actual user data", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:payloadDictionary];
            [[payload.userData should] equal:userData];
        });
        
        it(@"Should parse valid del collapse ids", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:payloadDictionary];
            [[payload.delCollapseIDs should] equal:@[
                @"collapse-id-1",
                @"collapse-id-2",
            ]];
        });
        
        it(@"Should not parse invalid del collapse ids", ^{
            NSMutableDictionary *newPayloadDict = [[NSMutableDictionary alloc] initWithDictionary:payloadDictionary];
            [newPayloadDict setDictionary:@{@"yamp" : @{@"del-collapse-ids" : @"collapse-id"}}];
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:newPayloadDict];
            [[payload.delCollapseIDs should] equal:@[]];
        });

        context(@"Attachment", ^{
            AMPAttachmentPayload *(^attachment)(NSDictionary *) = ^(NSDictionary *payloadDictionary) {
                AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:payloadDictionary];
                return payload.attachments.firstObject;
            };

            context(@"Valid", ^{
                it(@"Should have valid ID", ^{
                    [[attachment(payloadDictionary).identifier should] equal:attachmentID];
                });
                it(@"Should have valid URL", ^{
                    [[attachment(payloadDictionary).url.absoluteString should] equal:attachmentURL];
                });
                it(@"Should have valid type", ^{
                    [[attachment(payloadDictionary).fileUTI should] equal:attachmentType];
                });
            });

            context(@"Absent key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid attachments type", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @"", // Invalid type of 'a'
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid attachment type", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @[ @"" ], // Invalid type of element of 'a'
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid id", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @[
                            @{
                                @"l": @"https://ya.ru",
                                @"i": @[], // Invalid type
                            },
                        ],
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid url type", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @[
                            @{
                                @"l": @[], // Invalid type
                                @"i": @"ID",
                            },
                        ],
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid url value", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @[
                            @{
                                @"l": @"!!!not url!!!", // Invalid value
                                @"i": @"ID",
                            },
                        ],
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid file type", ^{
                NSDictionary *invalidPayloadDictionary = @{
                    @"aps" : payloadDictionary[@"aps"],
                    @"yamp" : @{
                        @"i" : notificationID,
                        @"a" : @[
                            @{
                                @"l": @"https://ya.ru", // Invalid value
                                @"i": @"ID",
                                @"t": @[]
                            },
                        ],
                    },
                };
                it(@"Should return nil attachment", ^{
                    [[attachment(invalidPayloadDictionary) should] beNil];
                });
            });

        });

        context(@"Lazy payload", ^{
            AMPLazyPayload *(^lazyPayload)(NSDictionary *) = ^(NSDictionary *payloadDictionary) {
                AMPPushNotificationPayload *payload =
                        [parser pushNotificationPayloadFromDictionary:payloadDictionary];
                return payload.lazy;
            };

            context(@"Valid", ^{
                it(@"Should have valid url", ^{
                    [[lazyPayload(payloadDictionary).url should] equal:lazyUrl];
                });
                it(@"Should have valid headers", ^{
                    [[lazyPayload(payloadDictionary).headers[lazyHeaderKey] should] equal:lazyHeaderValue];
                });
                it(@"Should have valid location min accuracy", ^{
                    [[lazyPayload(payloadDictionary).location.minAccuracy should] equal:lazyMinAccuracy];
                });
                it(@"Should have valid location min recency", ^{
                    [[lazyPayload(payloadDictionary).location.minRecency should] equal:lazyMinRecency];
                });
            });

            context(@"Absent key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                        },
                };
                it(@"Should return nil attachment", ^{
                    [[lazyPayload(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Invalid lazy payload type", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @"",
                        },
                };
                it(@"Should return nil lazy payload", ^{
                    [[lazyPayload(invalidPayloadDictionary) should] beNil];
                });
            });

            context(@"Absent lazy header key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @{
                                        @"a": lazyUrl
                                },
                        },
                };
                it(@"Should return nil headers", ^{
                    [[lazyPayload(invalidPayloadDictionary).headers should] beNil];
                });
            });

            context(@"Absent lazy location restrictions key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @{
                                        @"a": lazyUrl
                                },
                        },
                };
                it(@"Should return nil headers", ^{
                    [[lazyPayload(invalidPayloadDictionary).location should] beNil];
                });
            });

            context(@"Absent lazy location restrictions min recency key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @{
                                        @"a": lazyUrl,
                                        @"d": @{
                                                @"d": lazyMinAccuracy
                                        }
                                },
                        },
                };
                it(@"Should return nil headers", ^{
                    [[lazyPayload(invalidPayloadDictionary).location.minRecency should] beNil];
                    [[lazyPayload(invalidPayloadDictionary).location.minAccuracy should] equal:lazyMinAccuracy];
                });
            });

            context(@"Absent lazy location restrictions min accuracy key", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @{
                                        @"a": lazyUrl,
                                        @"d": @{
                                                @"c": lazyMinRecency
                                        }
                                },
                        },
                };
                it(@"Should return nil headers", ^{
                    [[lazyPayload(invalidPayloadDictionary).location.minRecency should] equal:lazyMinRecency];
                    [[lazyPayload(invalidPayloadDictionary).location.minAccuracy should] beNil];
                });
            });

            context(@"Absent lazy location restrictions subkeys", ^{
                NSDictionary *invalidPayloadDictionary = @{
                        @"aps" : payloadDictionary[@"aps"],
                        @"yamp" : @{
                                @"i" : notificationID,
                                @"g" : @{
                                        @"a": lazyUrl,
                                        @"d": @{}
                                },
                        },
                };
                it(@"Should return nil headers", ^{
                    [[lazyPayload(invalidPayloadDictionary).location.minRecency should] beNil];
                    [[lazyPayload(invalidPayloadDictionary).location.minAccuracy should] beNil];
                });
            });
        });
    });

    context(@"Silent push", ^{

        it(@"Should be not silent without 'content-available' key", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{}, @"yamp" : @{}}];
            [[theValue(payload.silent) should] beNo];
        });

        it(@"Should be not silent with 'content-available' key equal 0", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{ @"content-available" : @0 }, @"yamp" : @{}}];
            [[theValue(payload.silent) should] beNo];
        });

        it(@"Should be silent with 'content-available' key equal 1", ^{
            AMPPushNotificationPayload *payload =
                [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{ @"content-available" : @1 }, @"yamp" : @{}}];
            [[theValue(payload.silent) should] beYes];
        });
    });

    it(@"Should parse partial domain object", ^{
        NSString *notificationID = @"NOTIFICATION_ID";
        AMPPushNotificationPayload *payload =
            [parser pushNotificationPayloadFromDictionary:@{ @"aps" : @{}, @"yamp" : @{ @"i" : notificationID }}];
        [[payload.notificationID should] equal:notificationID];
    });

});

SPEC_END
