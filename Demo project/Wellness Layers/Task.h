//
//  Task.h
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/14/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (strong, nonatomic) NSNumber *taskID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (assign, nonatomic, readonly) BOOL isReported;

- (id)initWithDict:(NSDictionary *)dict;

@end
