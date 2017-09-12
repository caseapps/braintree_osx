#import <Braintree/BTClient.h>

#import "BTClientSpecHelper.h"
#import "BTTestClientTokenFactory.h"
#import "BTClient_Internal.h"

@implementation BTClientSpecHelper

+ (BTAPIClient *)asyncClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
    XCTestExpectation *expectation = [testCase expectationWithDescription:@"Setup client"];
    __block BTAPIClient *returnedClient;
    [BTAPIClient setupWithClientToken:clientToken completion:^(BTAPIClient *client, NSError *error) {
        NSAssert(client != nil && error == nil, @"setupWithClientToken:completion: should succeed");
        returnedClient = client;
        [expectation fulfill];
    }];

    [testCase waitForExpectationsWithTimeout:10 handler:nil];
    return returnedClient;
}

+ (BTAPIClient *)deprecatedClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides {
    NSString *clientToken = [BTTestClientTokenFactory tokenWithVersion:2 overrides:overrides];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTAPIClient *client = [[BTAPIClient alloc] initWithClientToken:clientToken];
#pragma clang diagnostic pop
    NSAssert(client != nil, @"initWithClientToken: should succeed");
    return client;
}

+ (BTAPIClient *)clientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides async:(BOOL)async {
    if (async) {
        return [self asyncClientForTestCase:testCase withOverrides:overrides];
    } else {
        return [self deprecatedClientForTestCase:testCase withOverrides:overrides];
    }
}

@end
