#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@class BTClient;

@interface BTClientSpecHelper : NSObject

+ (BTAPIClient *)asyncClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides;

+ (BTAPIClient *)deprecatedClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides;

+ (BTAPIClient *)clientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides async:(BOOL)async;

@end
