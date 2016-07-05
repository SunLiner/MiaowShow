//
//  ALinHomeADCell.m
//  MiaowShow
//
//  Created by ALin on 16/6/15.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinHomeADCell.h"
#import "ALinTopAD.h"


@implementation ALinHomeADCell
- (void)setTopADs:(NSArray *)topADs
{
    _topADs = topADs;
    
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (ALinTopAD *topAD in topADs) {
        [imageUrls addObject:topAD.imageUrl];
    }
    XRCarouselView *view = [XRCarouselView carouselViewWithImageArray:imageUrls describeArray:nil];
    view.time = 2.0;
    view.delegate = self;
    view.frame = self.contentView.bounds;
    [self.contentView addSubview:view];
}

#pragma mark - XRCarouselViewDelegate
- (void)carouselView:(XRCarouselView *)carouselView clickImageAtIndex:(NSInteger)index
{
    if (self.imageClickBlock) {
        self.imageClickBlock(self.topADs[index]);
    }
}
@end
