#import "BTClientStore.h"
#import "BTKeychain.h"
#import "BTClient_Internal.h"

@interface BTClientStore ()

@property (nonatomic, copy, readonly) NSString *keychainKey;

@end

static NSString *const keyPrefix = @"BTAppSwitchClientStore.";

@implementation BTClientStore

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [self init];
    if (self) {
        _keychainKey = [NSString stringWithFormat:@"%@%@", keyPrefix, identifier];
    }
    return self;
}

- (BTAPIClient *)fetchClient {
    NSData *clientData = [BTKeychain dataForKey:self.keychainKey];
    if (clientData == nil) {
        return nil;
    }

    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:clientData];
    BTAPIClient *client = [[BTAPIClient alloc] initWithCoder:decoder];
    [decoder finishDecoding];
    return client;
}

- (void)storeClient:(BTAPIClient *)client {
    NSMutableData *clientData = [NSMutableData data];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:clientData];
    [client encodeWithCoder:coder];
    [coder finishEncoding];

    [BTKeychain setData:clientData forKey:self.keychainKey];
}

@end
