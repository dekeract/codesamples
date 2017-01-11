//
//  PhaseHeaderView.h
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

@class Phase;

#import <UIKit/UIKit.h>

@interface PhaseHeaderView : UIView

@property (weak, nonatomic) Phase *phase;
@property (weak, nonatomic) NSString *avatarUrl;

@end
