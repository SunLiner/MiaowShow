//
//  ALinCareViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinCareViewController.h"


@interface ALinCareViewController ()
@property (weak, nonatomic) IBOutlet UIButton *toSeeBtn;

@end

@implementation ALinCareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toSeeBtn.layer.borderWidth = 1;
    self.toSeeBtn.layer.borderColor = KeyColor.CGColor;
    self.toSeeBtn.layer.cornerRadius = self.toSeeBtn.height * 0.5;
    [self.toSeeBtn.layer masksToBounds];
    
    [self.toSeeBtn setTitleColor:KeyColor forState:UIControlStateNormal];
}

- (IBAction)toSeeWorld {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyToseeBigWorld object:nil];
}

@end
