//
//  ALinHomeFlowLayout.m
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinHomeFlowLayout.h"

@implementation ALinHomeFlowLayout
- (void)prepareLayout
{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat wh = (ALinScreenWidth - 3) / 3.0;
    self.itemSize = CGSizeMake(wh , wh);
    self.minimumLineSpacing = 1;
    self.minimumInteritemSpacing = 1;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
}

@end
