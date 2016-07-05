//
//  ALinLiveCollectionViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/23.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinLiveCollectionViewController.h"
#import "ALinLiveViewCell.h"
#import "ALinRefreshGifHeader.h"
#import "ALinLiveFlowLayout.h"
#import "ALinUser.h"
#import "ALinUserView.h"

@interface ALinLiveCollectionViewController ()
/** 用户信息 */
@property (nonatomic, weak) ALinUserView *userView;
@end

@implementation ALinLiveCollectionViewController

static NSString * const reuseIdentifier = @"ALinLiveViewCell";

- (instancetype)init
{
    return [super initWithCollectionViewLayout:[[ALinLiveFlowLayout alloc] init]];
}

- (ALinUserView *)userView
{
    if (!_userView) {
        ALinUserView *userView = [ALinUserView userView];
        [self.collectionView addSubview:userView];
        _userView = userView;
        
        [userView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
            make.width.equalTo(@(ALinScreenWidth));
            make.height.equalTo(@(ALinScreenHeight));
        }];
        userView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [userView setCloseBlock:^{
            [UIView animateWithDuration:0.5 animations:^{
                self.userView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            } completion:^(BOOL finished) {
                [self.userView removeFromSuperview];
                self.userView = nil;
            }];
        }];
        
    }
    return _userView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[ALinLiveViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    ALinRefreshGifHeader *header = [ALinRefreshGifHeader headerWithRefreshingBlock:^{
        [self.collectionView.mj_header endRefreshing];
        self.currentIndex++;
        if (self.currentIndex == self.lives.count) {
            self.currentIndex = 0;
        }
        [self.collectionView reloadData];
    }];
    header.stateLabel.hidden = NO;
    [header setTitle:@"下拉切换另一个主播" forState:MJRefreshStatePulling];
    [header setTitle:@"下拉切换另一个主播" forState:MJRefreshStateIdle];
    self.collectionView.mj_header = header;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickUser:) name:kNotifyClickUser object:nil];
}

- (void)clickUser:(NSNotification *)notify
{
    if (notify.userInfo[@"user"] != nil) {
        ALinUser *user = notify.userInfo[@"user"];
        self.userView.user = user;
        [UIView animateWithDuration:0.5 animations:^{
            self.userView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALinLiveViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.parentVc = self;
    cell.live = self.lives[self.currentIndex];
    NSUInteger relateIndex = self.currentIndex;
    if (self.currentIndex + 1 == self.lives.count) {
        relateIndex = 0;
    }else{
        relateIndex += 1;
    }
    cell.relateLive = self.lives[relateIndex];
    [cell setClickRelatedLive:^{
        self.currentIndex += 1;
        [self.collectionView reloadData];
    }];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

@end
