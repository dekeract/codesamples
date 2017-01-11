//
//  NetworkManager.h
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

@class User, Phase;

#import "AFHTTPSessionManager.h"

@interface NetworkManager : AFHTTPSessionManager

+ (instancetype)manager;

- (void)loginWithEmail:(NSString *)email andPass:(NSString *)pass completion:(void (^)(User *user))completion;
- (void)getTasksListForUser:(User *)user completion:(void (^)(Phase *phase))completion;
- (void)reportTaskWithID:(NSNumber *)taskID forUser:(User *)user completion:(void (^)(BOOL success))completion;

@end
