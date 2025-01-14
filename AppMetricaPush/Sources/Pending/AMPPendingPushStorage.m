
#import "AMPPendingPushStorage.h"
#import "AMPPendingPushSerializer.h"
#import "AMPPendingPush.h"

static NSString *const kAMPPendingPushesKey = @"io.appmetrica.push.notifications.received";

@interface AMPPendingPushStorage ()

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;

@end

@implementation AMPPendingPushStorage

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self != nil) {
        _userDefaults = userDefaults;
    }
    return self;
}

- (void)addPendingPush:(AMPPendingPush *)push
{
    NSMutableArray *pushes =
        [[self pushesFromUserDefaults:self.userDefaults] mutableCopy] ?: [NSMutableArray array];
    [pushes addObject:[AMPPendingPushSerializer dictionaryForPush:push]];
    [self.userDefaults setObject:pushes forKey:kAMPPendingPushesKey];
}

- (NSArray<AMPPendingPush *> *)pendingPushes
{
    NSArray *pushDictionaries = [self pushesFromUserDefaults:self.userDefaults];
    NSMutableArray *pushes = [NSMutableArray arrayWithCapacity:pushDictionaries.count];
    for (NSDictionary *pushDictionary in pushDictionaries) {
        AMPPendingPush *push = [AMPPendingPushSerializer pushForDictionaty:pushDictionary];
        [pushes addObject:push];
    }
    return [pushes copy];
}

- (void)cleanup
{
    [self.userDefaults removeObjectForKey:kAMPPendingPushesKey];
}

- (NSArray *)pushesFromUserDefaults:(NSUserDefaults *)userDefaults
{
    return [userDefaults objectForKey:kAMPPendingPushesKey];
}

@end
