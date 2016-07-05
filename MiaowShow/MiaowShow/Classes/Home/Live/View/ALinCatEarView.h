//
//  ALinCatEarView.h
//  MiaowShow
//
//  Created by ALin on 16/6/17.
//  Copyright © 2016年 ALin. All rights reserved.
//  同一个工会的主播

#import <UIKit/UIKit.h>

@class ALinLive;
@interface ALinCatEarView : UIView
/** 主播/主播 */
@property(nonatomic, strong) ALinLive *live;
+ (instancetype)catEarView;
@end
