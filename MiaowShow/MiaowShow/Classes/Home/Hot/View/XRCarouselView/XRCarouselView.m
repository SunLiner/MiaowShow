//
//  XRCarouselView.m
//
//  Created by 肖睿 on 16/3/17.
//  Copyright © 2016年 肖睿. All rights reserved.
//

#import "XRCarouselView.h"


#define DEFAULTTIME 5
#define HORMARGIN 10
#define VERMARGIN 5
#define DES_LABEL_H 20
@interface XRCarouselView()<UIScrollViewDelegate>
//轮播的图片数组
@property (nonatomic, strong) NSMutableArray *images;
//图片描述控件，默认在底部
@property (nonatomic, strong) UILabel *describeLabel;
//滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;
//分页控件
@property (nonatomic, strong) UIPageControl *pageControl;
//当前显示的imageView
@property (nonatomic, strong) UIImageView *currImageView;
//滚动显示的imageView
@property (nonatomic, strong) UIImageView *otherImageView;
//当前显示图片的索引
@property (nonatomic, assign) NSInteger currIndex;
//将要显示图片的索引
@property (nonatomic, assign) NSInteger nextIndex;
//pageControl图片大小
@property (nonatomic, assign) CGSize pageImageSize;
//定时器
@property (nonatomic, strong) NSTimer *timer;
//任务队列
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation XRCarouselView
#pragma mark- 初始化方法
//创建用来缓存图片的文件夹
+ (void)initialize {
    NSString *cache = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"XRCarousel"];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cache isDirectory:&isDir];
    if (!isExists || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark- frame相关
- (CGFloat)height {
    return self.scrollView.frame.size.height;
}

- (CGFloat)width {
    return self.scrollView.frame.size.width;
}

#pragma mark- 懒加载
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        //添加手势监听图片的点击
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)]];
        _currImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_currImageView];
        _otherImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_otherImageView];
    }
    return _scrollView;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _describeLabel.textColor = [UIColor whiteColor];
        _describeLabel.textAlignment = NSTextAlignmentCenter;
        _describeLabel.font = [UIFont systemFontOfSize:13];
        _describeLabel.hidden = YES;
    }
    return _describeLabel;
}


- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

#pragma mark- 构造方法
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray {
    if (self = [super initWithFrame:frame]) {
        self.imageArray = imageArray;
    }
    return self;
}

- (instancetype)initWithImageArray:(NSArray *)imageArray imageClickBlock:(void(^)(NSInteger index))imageClickBlock {
    if (self = [self initWithFrame:CGRectZero imageArray:imageArray]) {
        self.imageClickBlock = imageClickBlock;
    }
    return self;
}

+ (instancetype)carouselViewWithImageArray:(NSArray *)imageArray describeArray:(NSArray *)describeArray {
    XRCarouselView *carouselView = [[self alloc] init];
    carouselView.imageArray = imageArray;
    carouselView.describeArray = describeArray;
    return carouselView;
}


#pragma mark- --------设置相关方法--------
#pragma mark 设置控件的frame，并添加子控件
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self addSubview:self.scrollView];
    [self addSubview:self.describeLabel];
    [self addSubview:self.pageControl];
}

#pragma mark 设置图片数组
- (void)setImageArray:(NSArray *)imageArray{
    if (!imageArray.count) return;
    _imageArray = imageArray;
    _images = [NSMutableArray array];
    
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            [_images addObject:imageArray[i]];
        } else if ([imageArray[i] isKindOfClass:[NSString class]]){
            //如果是网络图片，则先添加占位图片，下载完成后替换
            [_images addObject:[UIImage imageNamed:@"placeHolder_ad_414x100"]];
            [self downloadImages:i];
        }
    }
    
    //防止在滚动过程中重新给imageArray赋值时报错
    if (_currIndex >= _images.count) _currIndex = _images.count - 1;
    self.currImageView.image = _images[_currIndex];
    self.describeLabel.text = _describeArray[_currIndex];
    self.pageControl.numberOfPages = _images.count;
    [self layoutSubviews];
}


#pragma mark 设置描述数组
- (void)setDescribeArray:(NSArray *)describeArray{
    _describeArray = describeArray;
    if (!describeArray.count) {
        _describeArray = nil;
        self.describeLabel.hidden = YES;
    } else {
        //如果描述的个数与图片个数不一致，则补空字符串
        if (describeArray.count < _images.count) {
            NSMutableArray *describes = [NSMutableArray arrayWithArray:describeArray];
            for (NSInteger i = describeArray.count; i < _images.count; i++) {
                [describes addObject:@""];
            }
            _describeArray = describes;
        }
        self.describeLabel.hidden = NO;
        _describeLabel.text = _describeArray[_currIndex];
    }
    //重新计算pageControl的位置
    self.pagePosition = self.pagePosition;
}

#pragma mark 设置scrollView的contentSize
- (void)setScrollViewContentSize {
    if (_images.count > 1) {
        self.scrollView.contentSize = CGSizeMake(self.width * 5, 0);
        self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
        self.currImageView.frame = CGRectMake(self.width * 2, 0, self.width, self.height);
        if (_changeMode == ChangeModeFade) {
            //淡入淡出模式，两个imageView都在同一位置，改变透明度就可以了
            _currImageView.frame = CGRectMake(0, 0, self.width, self.height);
            _otherImageView.frame = self.currImageView.frame;
            _otherImageView.alpha = 0;
            [self insertSubview:self.currImageView atIndex:0];
            [self insertSubview:self.otherImageView atIndex:1];
        }
        [self startTimer];
    } else {
        //只要一张图片时，scrollview不可滚动，且关闭定时器
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, self.width, self.height);
        [self stopTimer];
    }
}

#pragma mark 设置图片描述控件
- (void)setDescribeTextColor:(UIColor *)color font:(UIFont *)font bgColor:(UIColor *)bgColor {
    if (color) self.describeLabel.textColor = color;
    if (font) self.describeLabel.font = font;
    if (bgColor) self.describeLabel.backgroundColor = bgColor;
}


#pragma mark 设置pageControl的指示器图片
- (void)setPageImage:(UIImage *)image andCurrentPageImage:(UIImage *)currentImage {
    if (!image || !currentImage) return;
    self.pageImageSize = image.size;
    [self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
    [self.pageControl setValue:image forKey:@"_pageImage"];
}

#pragma mark 设置pageControl的指示器颜色
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor {
    _pageControl.pageIndicatorTintColor = color;
    _pageControl.currentPageIndicatorTintColor = currentColor;
}

#pragma mark 设置pageControl的位置
- (void)setPagePosition:(PageControlPosition)pagePosition {
    _pagePosition = pagePosition;
    _pageControl.hidden = (_pagePosition == PositionHide) || (_imageArray.count == 1);
    if (_pageControl.hidden) return;
    
    CGSize size;
    if (!_pageImageSize.width) {//没有设置图片，系统原有样式
        size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
        size.height = 8;
    } else {//设置图片了
        size = CGSizeMake(_pageImageSize.width * (_pageControl.numberOfPages * 2 - 1), _pageImageSize.height);
    }
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat centerY = self.height - size.height * 0.5 - VERMARGIN - (_describeLabel.hidden?0: DES_LABEL_H);
    CGFloat pointY = self.height - size.height - VERMARGIN - (_describeLabel.hidden?0: DES_LABEL_H);
    
    if (_pagePosition == PositionNone || _pagePosition == PositionBottomCenter)
        _pageControl.center = CGPointMake(self.width * 0.5, centerY);
    else if (_pagePosition == PositionTopCenter)
        _pageControl.center = CGPointMake(self.width * 0.5, size.height * 0.5 + VERMARGIN);
    else if (_pagePosition == PositionBottomLeft)
        _pageControl.frame = CGRectMake(HORMARGIN, pointY, size.width, size.height);
    else
        _pageControl.frame = CGRectMake(self.width - HORMARGIN - size.width, pointY, size.width, size.height);
}

#pragma mark 设置定时器时间
- (void)setTime:(NSTimeInterval)time {
    _time = time;
    [self startTimer];
}

#pragma mark- --------定时器相关方法--------
- (void)startTimer {
    //如果只有一张图片，则直接返回，不开启定时器
    if (_images.count <= 1) return;
    //如果定时器已开启，先停止再重新开启
    if (self.timer) [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:_time < 2? DEFAULTTIME: _time target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage {
    if (_changeMode == ChangeModeFade) {
        //淡入淡出模式，不需要修改scrollview偏移量，改变两张图片的透明度即可
        self.nextIndex = (self.currIndex + 1) % _images.count;
        self.otherImageView.image = _images[_nextIndex];
        
        [UIView animateWithDuration:1.2 animations:^{
            self.currImageView.alpha = 0;
            self.otherImageView.alpha = 1;
            self.pageControl.currentPage = _nextIndex;
        } completion:^(BOOL finished) {
            [self changeToNext];
        }];
        
    } else [self.scrollView setContentOffset:CGPointMake(self.width * 3, 0) animated:YES];
}


#pragma mark- -----------其它-----------
#pragma mark 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    //有导航控制器时，会默认在scrollview上方添加64的内边距，这里强制设置为0
    _scrollView.contentInset = UIEdgeInsetsZero;
    
    _scrollView.frame = self.bounds;
    _describeLabel.frame = CGRectMake(0, self.height - DES_LABEL_H, self.width, DES_LABEL_H);
    //重新计算pageControl的位置
    self.pagePosition = self.pagePosition;
    [self setScrollViewContentSize];
}


#pragma mark 图片点击事件
- (void)imageClick {
    if (self.imageClickBlock) {
        self.imageClickBlock(self.currIndex);
    } else if ([_delegate respondsToSelector:@selector(carouselView:clickImageAtIndex:)]){
        [_delegate carouselView:self clickImageAtIndex:self.currIndex];
    }
}

#pragma mark 下载网络图片
- (void)downloadImages:(int)index {
    NSString *key = _imageArray[index];
    //从沙盒中取图片
    NSString *path = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"XRCarousel"] stringByAppendingPathComponent:[key lastPathComponent]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        _images[index] = [UIImage imageWithData:data];
        return;
    }
    //下载图片
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:key]];
        if (!data) return;
        UIImage *image = [UIImage imageWithData:data];
        //取到的data有可能不是图片
        if (image) {
            self.images[index] = image;
            //如果下载的图片为当前要显示的图片，直接到主线程给imageView赋值，否则要等到下一轮才会显示
            if (_currIndex == index) [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            [data writeToFile:path atomically:YES];
        }
    }];
    [self.queue addOperation:download];
}

#pragma mark 清除沙盒中的图片缓存
- (void)clearDiskCache {
    NSString *cache = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"XRCarousel"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cache error:NULL];
    for (NSString *fileName in contents) {
        [[NSFileManager defaultManager] removeItemAtPath:[cache stringByAppendingPathComponent:fileName] error:nil];
    }
}

#pragma mark 当图片滚动过半时就修改当前页码
- (void)changeCurrentPageWithOffset:(CGFloat)offsetX {
    if (offsetX < self.width * 1.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.images.count - 1;
        _pageControl.currentPage = index;
    } else if (offsetX > self.width * 2.5){
        _pageControl.currentPage = (self.currIndex + 1) % self.images.count;
    } else {
        _pageControl.currentPage = self.currIndex;
    }
}

#pragma mark- --------UIScrollViewDelegate--------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (CGSizeEqualToSize(CGSizeZero, scrollView.contentSize)) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    //滚动过程中改变pageControl的当前页码
    [self changeCurrentPageWithOffset:offsetX];
    
    //向右滚动
    if (offsetX < self.width * 2) {
        if (_changeMode == ChangeModeFade) {
            self.currImageView.alpha = offsetX / self.width - 1;
            self.otherImageView.alpha = 2 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(self.width, 0, self.width, self.height);
        
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) self.nextIndex = _images.count - 1;
        if (offsetX <= self.width) [self changeToNext];
        
    //向左滚动
    } else if (offsetX > self.width * 2){
        if (_changeMode == ChangeModeFade) {
            self.otherImageView.alpha = offsetX / self.width - 2;
            self.currImageView.alpha = 3 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
        
        self.nextIndex = (self.currIndex + 1) % _images.count;
        if (offsetX >= self.width * 3) [self changeToNext];
    }
    self.otherImageView.image = self.images[self.nextIndex];
}

- (void)changeToNext {
    if (_changeMode == ChangeModeFade) {
        self.currImageView.alpha = 1;
        self.otherImageView.alpha = 0;
    }
    //切换到下一张图片
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
    self.currIndex = self.nextIndex;
    self.pageControl.currentPage = self.currIndex;
    self.describeLabel.text = self.describeArray[self.currIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}

@end
