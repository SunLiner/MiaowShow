//
//  ALinHomeADCell.h
//  MiaowShow
//
//  Created by ALin on 16/6/15.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XRCarouselView.h"

@class ALinTopAD;

@interface ALinHomeADCell : UITableViewCell <XRCarouselViewDelegate>
/** 顶部AD数组 */
@property (nonatomic, strong) NSArray *topADs;
/** 点击图片的block */
@property (nonatomic, copy) void (^imageClickBlock)(ALinTopAD *topAD);
@end
