//
//  Task.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _taskID = [dict objectForKey:@"OriginalPhaseTaskID"];
        _title = [dict objectForKey:@"Title"];
        _subtitle = [dict objectForKey:@"SubTitle"];
        _isReported = [[dict objectForKey:@"Reported"] boolValue];
    }
    return self;
}

@end
