//
//  Phase.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "Phase.h"
#import "Task.h"

@implementation Phase

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _name = [dict objectForKey:@"PhaseName"];
        _moto = [dict objectForKey:@"PhaseMotto"];
        
        NSMutableArray *tasks = [NSMutableArray new];
        for (NSDictionary *rawTask in [dict objectForKey:@"PhaseTasks"]) {
            Task *task = [[Task alloc] initWithDict:rawTask];
            [tasks addObject:task];
        }
        _tasks = tasks;
    }
    return self;
}

@end
