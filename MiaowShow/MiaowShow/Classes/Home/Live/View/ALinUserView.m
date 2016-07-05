//
//  ALinUserView.m
//  MiaowShow
//
//  Created by ALin on 16/6/28.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinUserView.h"
#import "ALinUser.h"
#import "UIImage+ALinExtension.h"
#import <SDWebImageDownloader.h>

@interface ALinUserView()
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *careNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNumLabel;
@property (weak, nonatomic) IBOutlet UIView *userView;

@end
@implementation ALinUserView

+ (instancetype)userView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.careNumLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(5000) + 500];
    self.fansNumLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(30000) + 500];
    self.userView.layer.cornerRadius = 10;
    self.userView.layer.masksToBounds = YES;
}

- (void)setUser:(ALinUser *)user
{
    _user = user;
    self.nickNameLabel.text = user.nickname;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:user.photo] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coverView.image = [UIImage circleImage:image borderColor:[UIColor whiteColor] borderWidth:1];
        });
    }];
}

- (IBAction)care:(UIButton *)sender {
}

- (IBAction)tipoffs {
    [self showInfo:@"举报成功"];
}

- (IBAction)close {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
