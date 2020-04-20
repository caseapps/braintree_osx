//
//  AppDelegate.m
//  Braintree-OSX-Demo
//
//  Created by Martin Kahr on 20.04.20.
//

#import "AppDelegate.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString* clientToken = @"";
    
    BTAPIClient* braintree = [[BTAPIClient alloc] initWithAuthorization:clientToken];
    NSLog(@"%@", braintree);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
