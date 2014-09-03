#import <Foundation/Foundation.h>

#import "BTClient.h"

#import "BTPaymentAuthorizationDelegate.h"

@interface BTPaymentAuthorizer : NSObject

- (instancetype)initWithType:(BTPaymentAuthorizationType)type
                      client:(BTClient *)client;

- (void)authorize;

@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

@end
