//
//  User.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _fullName = [[dict objectForKey:@"User"] objectForKey:@"FullName"];
        _avatarImageUrl = [[dict objectForKey:@"User"] objectForKey:@"PhotoURL"];
        _groupPlanID = [[dict objectForKey:@"User"] objectForKey:@"GroupPlanID"];
        _userPlanPhaseID = [[dict objectForKey:@"User"] objectForKey:@"UserPlanPhaseID"];
        
        _authToken = [[dict objectForKey:@"Tokens"] objectForKey:@"AuthToken"];
        _sessionToken = [[dict objectForKey:@"Tokens"] objectForKey:@"SessionToken"];
    }
    return self;
}

@end
