#import "BTClient.h"

SpecBegin(BTVersionSpec)

it(@"returns the current version", ^{
    expect([BTAPIClient libraryVersion]).to.match(@"\\d+\\.\\d+\\.\\d+");
});

SpecEnd
