//
//  ALinNewStarViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinNewStarViewController.h"
#import "ALinUser.h"
#import "ALinAnchorViewCell.h"
#import "ALinHomeFlowLayout.h"
#import "ALinRefreshGifHeader.h"
#import "ALinLiveCollectionViewController.h"
#import "ALinLive.h"

@interface ALinNewStarViewController ()
/** 最新主播列表 */
@property(nonatomic, strong) NSMutableArray *anchors;
/** 当前页 */
@property(nonatomic, assign) NSUInteger currentPage;
/** NSTimer */
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ALinNewStarViewController

static NSString * const reuseIdentifier = @"NewStarCell";

- (NSMutableArray *)anchors
{
    if (!_anchors) {
        _anchors = [NSMutableArray array];
    }
    return _anchors;
}

- (instancetype)init
{
    return [super initWithCollectionViewLayout:[[ALinHomeFlowLayout alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 首先自动刷新一次
    [self autoRefresh];
    // 然后开启每一分钟自动更新
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(autoRefresh) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setup
{
    // 默认当前页从1开始的
    self.currentPage = 1;
    // 注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ALinAnchorViewCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // 设置header和footer
    self.collectionView.mj_header = [ALinRefreshGifHeader headerWithRefreshingBlock:^{
        self.currentPage = 1;
        self.anchors = [NSMutableArray array];
        [self getAnchorsList];
    }];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.currentPage++;
        [self getAnchorsList];
    }];
    [self.collectionView.mj_header beginRefreshing];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefresh) name:kNotifyRefreshNew object:nil];
    
}

- (void)autoRefresh
{
    [self.collectionView.mj_header beginRefreshing];
    NSLog(@"刷新最新主播界面");
}


// 获取数据
- (void)getAnchorsList
{
    [[ALinNetworkTool shareTool] GET:[NSString stringWithFormat:@"http://live.9158.com/Room/GetNewRoomOnline?page=%ld", self.currentPage] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        NSString *statuMsg = responseObject[@"msg"];
        if ([statuMsg isEqualToString:@"fail"]) { // 数据已经加载完毕, 没有更多数据了
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            [self showHint:@"暂时没有更多最新数据"];
            // 恢复当前页
            self.currentPage--;
        }else{
            [responseObject[@"data"][@"list"] writeToFile:@"/Users/apple/Desktop/user.plist" atomically:YES];
            NSArray *result = [ALinUser mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"list"]];
            if (result.count) {
                [self.anchors addObjectsFromArray:result];
                [self.collectionView reloadData];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
        self.currentPage--;
        [self showHint:@"网络异常"];
    }];
}

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.anchors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALinAnchorViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.user = self.anchors[indexPath.item];
    return cell;
}


#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALinLiveCollectionViewController *liveVc = [[ALinLiveCollectionViewController alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    for (ALinUser *user in self.anchors) {
        ALinLive *live = [[ALinLive alloc] init];
        live.bigpic = user.photo;
        live.myname = user.nickname;
        live.smallpic = user.photo;
        live.gps = user.position;
        live.useridx = user.useridx;
        live.allnum = arc4random_uniform(2000);
        live.flv = user.flv;
        [array addObject:live];
    }
    liveVc.lives = array;
    liveVc.currentIndex = indexPath.item;
    [self presentViewController:liveVc animated:YES completion:nil];
}
@end
