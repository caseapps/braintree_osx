#import "BTAnalyticsMetadata.h"
#import "BTClient.h"

#import "BTKeychain.h"
@import CoreLocation;
#import <sys/sysctl.h>
#import <sys/utsname.h>

#ifndef TARGET_OS_MAC
#import <UIKit/UIKit.h>
#endif

#ifdef __IPHONE_8_0
#define kBTCLAuthorizationStatusAuthorized kCLAuthorizationStatusAuthorizedAlways
#else
#define kBTCLAuthorizationStatusAuthorized kCLAuthorizationStatusAuthorized
#endif

@implementation BTAnalyticsMetadata

+ (NSDictionary *)metadata {
    BTAnalyticsMetadata *m = [[BTAnalyticsMetadata alloc] init];

    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:16];

    [self setObject:[m platform] forKey:@"platform" inDictionary:data];
    [self setObject:[m platformVersion] forKey:@"platformVersion" inDictionary:data];
    [self setObject:[m sdkVersion] forKey:@"sdkVersion" inDictionary:data];
    [self setObject:[m merchantAppId] forKey:@"merchantAppId" inDictionary:data];
    [self setObject:[m merchantAppName] forKey:@"merchantAppName" inDictionary:data];
    [self setObject:[m merchantAppVersion] forKey:@"merchantAppVersion" inDictionary:data];
#ifndef __IPHONE_8_0
    [self setObject:@([m deviceRooted]) forKey:@"deviceRooted" inDictionary:data];
#endif
    [self setObject:[m deviceManufacturer] forKey:@"deviceManufacturer" inDictionary:data];
    [self setObject:[m deviceModel] forKey:@"deviceModel" inDictionary:data];
#ifndef TARGET_OS_MAC
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kBTCLAuthorizationStatusAuthorized) {
        [self setObject:@([m deviceLocationLatitude]) forKey:@"deviceLocationLatitude" inDictionary:data];
        [self setObject:@([m deviceLocationLongitude]) forKey:@"deviceLocationLongitude" inDictionary:data];
    }
    [self setObject:[m iosDeviceName] forKey:@"iosDeviceName" inDictionary:data];
    [self setObject:[m iosSystemName] forKey:@"iosSystemName" inDictionary:data];
    [self setObject:[m iosBaseSDK] forKey:@"iosBaseSDK" inDictionary:data];
    [self setObject:[m iosDeploymentTarget] forKey:@"iosDeploymentTarget" inDictionary:data];
    [self setObject:[m iosIdentifierForVendor] forKey:@"iosIdentifierForVendor" inDictionary:data];
#endif
    [self setObject:@([m iosIsCocoapods]) forKey:@"iosIsCocoapods" inDictionary:data];
    [self setObject:[m deviceAppGeneratedPersistentUuid] forKey:@"deviceAppGeneratedPersistentUuid" inDictionary:data];
    [self setObject:@([m isSimulator]) forKey:@"isSimulator" inDictionary:data];
    [self setObject:[m deviceScreenOrientation] forKey:@"deviceScreenOrientation" inDictionary:data];
    [self setObject:[m userInterfaceOrientation] forKey:@"userInterfaceOrientation" inDictionary:data];

    return [NSDictionary dictionaryWithDictionary:data];
}

+ (void)setObject:(id)object forKey:(id<NSCopying>)aKey inDictionary:(NSMutableDictionary *)dictionary {
    if (object) {
        [dictionary setObject:object forKey:aKey];
    }
}

#pragma mark Metadata Factors

- (NSString *)platform {
    return @"iOS";
}

- (NSString *)platformVersion {
#ifdef TARGET_OS_MAC
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return [NSString stringWithFormat: @"%ld.%ld.%ld", (long)version.majorVersion, version.minorVersion, version.patchVersion];
#else
    return [[UIDevice currentDevice] systemVersion];
#endif
}

- (NSString *)sdkVersion {
    return [BTAPIClient libraryVersion];
}

- (NSString *)merchantAppId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
}

- (NSString *)merchantAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
}

- (NSString *)merchantAppName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleNameKey];
}

- (BOOL)deviceRooted {
#if TARGET_IPHONE_SIMULATOR || __IPHONE_8_0
    return NO;
#else
    BOOL isJailbroken = system(NULL) == 1;

    return isJailbroken;
#endif
}

- (NSString *)deviceManufacturer {
    return @"Apple";
}

- (NSString *)deviceModel {
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];


    return code;
}

- (CLLocationDegrees)deviceLocationLatitude {
    return [[[[CLLocationManager alloc] init] location] coordinate].latitude;
}

- (CLLocationDegrees)deviceLocationLongitude {
    return [[[[CLLocationManager alloc] init] location] coordinate].longitude;
}
#ifndef TARGET_OS_MAC
- (NSString *)iosIdentifierForVendor {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)iosDeploymentTarget {
    return [@(__IPHONE_OS_VERSION_MIN_REQUIRED) stringValue];
}

- (NSString *)iosBaseSDK {
    return [@(__IPHONE_OS_VERSION_MAX_ALLOWED) stringValue];
}

- (NSString *)iosDeviceName {
    return [[UIDevice currentDevice] name];
}

- (NSString *)iosSystemName {
    return [[UIDevice currentDevice] systemName];
}
#endif

- (BOOL)iosIsCocoapods {
#ifdef COCOAPODS
    return YES;
#else
    return NO;
#endif
}

- (NSString *)deviceAppGeneratedPersistentUuid {
    @try {
        static NSString *deviceAppGeneratedPersistentUuidKeychainKey = @"deviceAppGeneratedPersistentUuid";
        NSString *savedIdentifier = [BTKeychain stringForKey:deviceAppGeneratedPersistentUuidKeychainKey];
        if (savedIdentifier.length == 0) {
            savedIdentifier = [[NSUUID UUID] UUIDString];
            BOOL setDidSucceed = [BTKeychain setString:savedIdentifier
                                                forKey:deviceAppGeneratedPersistentUuidKeychainKey];
            if (!setDidSucceed) {
                return nil;
            }
        }
        return savedIdentifier;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)isSimulator {
    return TARGET_IPHONE_SIMULATOR;
}

- (NSString *)userInterfaceOrientation {
// UIViewController interface orientation methods are deprecated as of iOS 8
#ifndef __IPHONE_8_0
    if ([UIApplication class] == nil) {
        return nil;
    }

    UIInterfaceOrientation deviceOrientation = [[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation];

    switch (deviceOrientation) {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
#else
    return nil;
#endif
}

- (NSString *)deviceScreenOrientation {
#ifdef TARGET_OS_MAC
    return nil;
#else
    if ([UIDevice class] == nil) {
        return nil;
    }

    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationFaceUp:
            return @"FaceUp";
        case UIDeviceOrientationFaceDown:
            return @"FaceDown";
        case UIDeviceOrientationPortrait:
            return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIDeviceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
#endif
}


@end
