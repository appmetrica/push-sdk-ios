
#import <Foundation/Foundation.h>

@interface AMPAttachmentPayload : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSString *fileUTI;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithIdentifier:(NSString *)identifier url:(NSURL *)url fileUTI:(NSString *)fileUTI;

@end
