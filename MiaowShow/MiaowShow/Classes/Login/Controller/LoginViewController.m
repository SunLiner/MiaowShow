//
//  LoginViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/13.
//  Copyright © 2016年 ALin. All rights reserved.
//


#import "LoginViewController.h"
#import "ThirdLoginView.h"
#import "MainViewController.h"


@interface LoginViewController ()
/** player */
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
/** 第三方登录 */
@property (nonatomic, weak) ThirdLoginView *thirdView;
/** 快速通道 */
@property (nonatomic, weak) UIButton *quickBtn;
/** 封面图片 */
@property (nonatomic, weak) UIImageView *coverView;
@end

@implementation LoginViewController

#pragma mark - 懒加载

- (IJKFFMoviePlayerController *)player
{
    if (!_player) {
        // 随机播放一组视频
        NSString *path = arc4random_uniform(10) % 2 ? @"login_video" : @"loginmovie";
        IJKFFMoviePlayerController *player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:[[NSBundle mainBundle] pathForResource:path ofType:@"mp4"] withOptions:[IJKFFOptions optionsByDefault]];
        // 设计player
        player.view.frame = self.view.bounds;
        // 填充fill
        player.scalingMode = IJKMPMovieScalingModeAspectFill;
        [self.view addSubview:player.view];
        // 设置自动播放
        player.shouldAutoplay = NO;
        // 准备播放
        [player prepareToPlay];
        
        _player = player;
    }
    return _player;
}

- (ThirdLoginView *)thirdView
{
    if (!_thirdView) {
        ThirdLoginView *third = [[ThirdLoginView alloc] initWithFrame:CGRectMake(0, 0, 400, 200)];
        [third setClickLogin:^(LoginType type) {
            [self loginSuccess];
        }];
        third.hidden = YES;
        [self.view addSubview:third];
        _thirdView = third;
    }
    return _thirdView;
}

- (UIButton *)quickBtn
{
    if (!_quickBtn) {
        UIButton *btn = [[UIButton alloc] init];
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor yellowColor].CGColor;
        [btn setTitle:@"ALin快速通道" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor yellowColor]  forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(loginSuccess) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn.hidden = YES;
        _quickBtn = btn;
    }
    return _quickBtn;
}

- (UIImageView *)coverView
{
    if (!_coverView) {
        UIImageView *cover = [[UIImageView alloc] initWithFrame:self.view.bounds];
        cover.image = [UIImage imageNamed:@"LaunchImage"];
        [self.player.view addSubview:cover];
        _coverView = cover;
    }
    return _coverView;
}


#pragma mark - lifr circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.player shutdown];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.player.view removeFromSuperview];
    self.player = nil;
    
}


- (void)setup
{
    [self initObserver];
    
    self.coverView.hidden = NO;
    
    [self.quickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.right.equalTo(@-40);
        make.bottom.equalTo(@-60);
        make.height.equalTo(@40);
    }];
    
    [self.thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@60);
        make.bottom.equalTo(self.quickBtn.mas_top).offset(-40);
    }];
    
}


#pragma mark - private method

- (void)initObserver
{
    // 监听视频是否播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
}


- (void)stateDidChange
{
    if ((self.player.loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        if (!self.player.isPlaying) {
            self.coverView.frame = self.view.bounds;
            [self.view insertSubview:self.coverView atIndex:0];
            [self.player play];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.thirdView.hidden = NO;
                self.quickBtn.hidden = NO;
            });
        }
    }
}

- (void)didFinish
{
    // 播放完之后, 继续重播
    [self.player play];
}

// 登录成功
- (void)loginSuccess
{
    [self showHint:@"登录成功"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:[[MainViewController alloc] init] animated:NO completion:^{
            [self.player stop];
            [self.player.view removeFromSuperview];
            self.player = nil;
        }];
    });
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
