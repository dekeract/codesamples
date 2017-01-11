//
//  PhaseHeaderView.m
//  Wellness Layers
//
//  Created by Dima Nikolayenko on 4/15/16.
//  Copyright © 2016 Dima Nikolayenko. All rights reserved.
//

#import "PhaseHeaderView.h"
#import "Phase.h"
#import "UIImageView+AFNetworking.h"

@interface PhaseHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *motoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation PhaseHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 45;
}

- (void)setPhase:(Phase *)phase
{
    self.nameLabel.text = phase.name;
    self.motoLabel.text = phase.moto;
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]];
}

@end
