#import "BTClient.h"

typedef NS_ENUM(NSUInteger, BTVenmoStatus) {
    BTVenmoStatusOff = 0,
    BTVenmoStatusOffline,
    BTVenmoStatusProduction
};

@interface BTAPIClient (BTVenmo)

- (BTVenmoStatus)btVenmo_status;

@end
