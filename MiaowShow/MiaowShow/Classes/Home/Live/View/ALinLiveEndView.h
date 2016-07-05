//
//  ALinLiveEndView.h
//  MiaowShow
//
//  Created by ALin on 16/7/1.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALinLiveEndView : UIView
+ (instancetype)liveEndView;
/** 查看其他主播 */
@property (nonatomic, copy) void (^lookOtherBlock)();
/** 退出 */
@property (nonatomic, copy) void (^quitBlock)();
@end
