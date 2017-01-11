//
//  Phase.h
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

@class Task;

#import <Foundation/Foundation.h>

@interface Phase : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *moto;

@property (strong, nonatomic, readonly) NSArray<Task *> *tasks;

- (id)initWithDict:(NSDictionary *)dict;

@end
