//
//  ThirdLoginView.h
//  MiaowShow
//
//  Created by ALin on 16/6/13.
//  Copyright © 2016年 ALin. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, LoginType) {
    LoginTypeSina,
    LoginTypeQQ,
    LoginTypeWechat
};

@interface ThirdLoginView : UIView
/** 点击按钮 */
@property (nonatomic, copy) void (^clickLogin)(LoginType type);
@end
