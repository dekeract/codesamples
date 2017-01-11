
#import "DKShop.h"
#import "DKDataStore.h"
#import <CoreLocation/CLLocation.h>

const NSInteger kLocationDivider = 1000000;

@interface DKShop () <NSCoding>

@end

@implementation DKShop

+ (void)getListOfShops:(void (^)(BOOL success, NSArray *shops))completion
{
    [[DKDataStore defaultDataStore] getStoresList:^(BOOL success, NSArray *stores) {
        if (completion) {
            completion(success, stores);
        }
    }];
}

- (void)loadListOfInstruments:(void (^)(BOOL success))completion
{
    [[DKDataStore defaultDataStore] getInstrumentsListForShop:self.ID callback:^(BOOL success, NSArray *instruments) {
        if (completion) {
            if (instruments) {
                self.instruments = instruments;
            }
            
            completion(success);
        }
    }];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _ID = [dict objectForKey:@"id"];
        _name = [dict objectForKey:@"name"];
        _address = [dict objectForKey:@"address"];
        _phone = [dict objectForKey:@"phone"];
        _website = [dict objectForKey:@"website"];
        
        NSDictionary *locationDict = [dict objectForKey:@"location"];
        
        double latitude = [[locationDict objectForKey:@"latitude"] doubleValue] / kLocationDivider;
        double longtitude = [[locationDict objectForKey:@"longitude"] doubleValue] / kLocationDivider;
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.website forKey:@"website"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.instruments forKey:@"instruments"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _ID = [aDecoder decodeObjectForKey:@"id"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _address = [aDecoder decodeObjectForKey:@"address"];
        _phone = [aDecoder decodeObjectForKey:@"phone"];
        _website = [aDecoder decodeObjectForKey:@"website"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _instruments = [aDecoder decodeObjectForKey:@"instruments"];
    }
    return self;
}

@end
