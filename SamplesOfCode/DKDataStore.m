
#import "DKDataStore.h"
#import "AFNetworking.h"
#import "DKShop.h"
#import "DKInstrument.h"

static NSString *kCacheFileName = @"shopsCache";

@interface DKDataStore ()

@property (strong, nonatomic) NSArray *shops;

@end

@implementation DKDataStore

+ (instancetype)defaultDataStore
{
    static DKDataStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DKDataStore alloc] init];
    });
    return sharedInstance;
}

- (void)getStoresList:(void (^)(BOOL success, NSArray *stores))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kAPIBaseUrl, kStoresUrl];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *shops = [NSMutableArray new];
        for (NSDictionary *rawShop in responseObject) {
            DKShop *shop = [[DKShop alloc] initWithDictionary:rawShop];
            [shops addObject:shop];
        }
        
        self.shops = shops;
        [self saveData];
        
        if (completion) {
            completion(YES, self.shops);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED| getStoreList: %@", error);
        
        if (completion) {
            [self loadData];
            completion((self.shops != nil), self.shops);
        }
    }];
    
}

- (void)getInstrumentsListForShop:(NSNumber *)shopID callback:(void (^)(BOOL success, NSArray *instruments))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@", kAPIBaseUrl, kStoresUrl, shopID, kInstrumentsUrl];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *instruments = [NSMutableArray new];
        for (NSDictionary *rawInstrument in responseObject) {
            DKInstrument *instrument = [[DKInstrument alloc] initWithDictionary:rawInstrument];
            [instruments addObject:instrument];
        }
        
        if (completion) {
            completion(YES, instruments);
        }
        
        [self saveData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED| getStoreList: %@", error);
        
        if (completion) {
            completion(NO, nil);
        }
    }];
}

#pragma mark - Private

- (void)saveData
{
    if (self.shops) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.shops];
        NSString *fileUrl = [[self documentDirectory] stringByAppendingPathComponent:kCacheFileName];
        [data writeToFile:fileUrl atomically:YES];
    }
}

- (NSArray *)loadData
{
    NSString *fileUrl = [[self documentDirectory] stringByAppendingPathComponent:kCacheFileName];
    NSData *data = [NSData dataWithContentsOfFile:fileUrl];
    self.shops = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return self.shops;
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

@end
