

#import "DKInstrument.h"

@interface DKInstrument () <NSCoding>

@end

@implementation DKInstrument

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *instrumentDict = [dict objectForKey:@"instrument"];
        
        _ID = [instrumentDict objectForKey:@"id"];
        _brand = [instrumentDict objectForKey:@"brand"];
        _model = [instrumentDict objectForKey:@"model"];
        _type = [instrumentDict objectForKey:@"type"];
        _price = [instrumentDict objectForKey:@"price"];
        _quantity = [dict objectForKey:@"quantity"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"id"];
    [aCoder encodeObject:self.brand forKey:@"brand"];
    [aCoder encodeObject:self.model forKey:@"model"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.quantity forKey:@"quantity"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _ID = [aDecoder decodeObjectForKey:@"id"];
        _brand = [aDecoder decodeObjectForKey:@"brand"];
        _model = [aDecoder decodeObjectForKey:@"model"];
        _type = [aDecoder decodeObjectForKey:@"type"];
        _price = [aDecoder decodeObjectForKey:@"price"];
        _quantity = [aDecoder decodeObjectForKey:@"quantity"];
    }
    return self;
}

@end
