//
//  User.h
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSNumber *groupPlanID;
@property (strong, nonatomic) NSNumber *userPlanPhaseID;

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *avatarImageUrl;

@property (strong, nonatomic, readonly) NSString *authToken;
@property (strong, nonatomic, readonly) NSString *sessionToken;

- (id)initWithDict:(NSDictionary *)dict;

@end
