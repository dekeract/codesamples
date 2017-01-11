//
//  NetworkManager.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "NetworkManager.h"
#import "User.h"
#import "Phase.h"

static NSString *kBaseUrl = @"https://dev-mdt-api.wellnesslayers.com/Api/";
static NSString *kLoginUrl = @"Account/Login";
static NSString *kTasksListUrl = @"Patients/CoachingPlan/PatientPlan";
static NSString *kReportTaskUrl = @"Patients/CoachingPlan/ReportItem";

@implementation NetworkManager

+ (instancetype)manager
{
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        sharedInstance.requestSerializer = [AFJSONRequestSerializer serializer];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        
        sharedInstance.securityPolicy = securityPolicy;
    });
    return sharedInstance;
}

- (void)loginWithEmail:(NSString *)email andPass:(NSString *)pass completion:(void (^)(User *user))completion
{
    NSDictionary *params = @{@"UserName": @"stastrav2", @"Password": @"5e065cdcc904fa398b8b0db3aa268e9f"};
    
    [self POST:kLoginUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        User *user = [[User alloc] initWithDict:responseObject];
        if (completion) {
            completion(user);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Login failed - %@", error.localizedDescription);
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)getTasksListForUser:(User *)user completion:(void (^)(Phase *phase))completion
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-mm-dd"];
    NSDictionary *params = @{@"planID": user.groupPlanID, @"phaseID": user.userPlanPhaseID, @"reportDate": [dateFormatter stringFromDate:date]};
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:user.authToken forHTTPHeaderField:@"AuthToken"];
    [requestSerializer setValue:user.sessionToken forHTTPHeaderField:@"SessionToken"];
    self.requestSerializer = requestSerializer;
    
    [self GET:kTasksListUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        Phase *phase = [[Phase alloc] initWithDict:responseObject];
        if (completion) {
            completion(phase);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Login failed - %@", error.localizedDescription);
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)reportTaskWithID:(NSNumber *)taskID forUser:(User *)user completion:(void (^)(BOOL success))completion
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-mm-dd"];
 
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:user.authToken forHTTPHeaderField:@"AuthToken"];
    [requestSerializer setValue:user.sessionToken forHTTPHeaderField:@"SessionToken"];
    self.requestSerializer = requestSerializer;
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@?planItemID=%@&reportDate=%@", kReportTaskUrl, taskID, [dateFormatter stringFromDate:date]];
    
    [self PUT:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Login failed - %@", error.localizedDescription);
        if (completion) {
            completion(NO);
        }
    }];
}

@end
