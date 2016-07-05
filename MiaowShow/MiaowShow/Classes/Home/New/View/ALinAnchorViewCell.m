//
//  ALinAnchorViewCell.m
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinAnchorViewCell.h"
#import "ALinUser.h"
#import <UIImageView+WebCache.h>

@interface ALinAnchorViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *star;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@end
@implementation ALinAnchorViewCell

- (void)setUser:(ALinUser *)user
{
    _user = user;
    // 设置封面头像
    [_coverView sd_setImageWithURL:[NSURL URLWithString:user.photo] placeholderImage:[UIImage imageNamed:@"placeholder_head"]];
    // 是否是新主播
    self.star.hidden = !user.newStar;
    // 地址
    [self.locationBtn setTitle:user.position forState:UIControlStateNormal];
    // 主播名
    self.nickNameLabel.text = user.nickname;
}

@end
