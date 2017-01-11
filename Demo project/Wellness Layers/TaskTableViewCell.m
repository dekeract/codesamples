//
//  TaskTableViewCell.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "Task.h"

@interface TaskTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reportedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;

@end

@implementation TaskTableViewCell

- (void)setTask:(Task *)task
{
    self.titleLabel.text = task.title;
    [self.titleLabel sizeToFit];
    self.titleWidthConstraint.constant = self.titleLabel.frame.size.width;
    self.subtitleLabel.text  = task.subtitle;
    
    self.reportedImageView.hidden = !task.isReported;
}

- (void)animateReportImageView
{
    self.reportedImageView.hidden = NO;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:2];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.reportedImageView.center.x - 5.0f, self.reportedImageView.center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.reportedImageView.center.x + 5.0f, self.reportedImageView.center.y)]];
    [self.reportedImageView.layer addAnimation:animation forKey:@"position"];
}

@end
