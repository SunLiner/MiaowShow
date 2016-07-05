//
//  ALinAnchorViewCell.h
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALinUser;

@interface ALinAnchorViewCell : UICollectionViewCell
/** 主播 */
@property(nonatomic, strong) ALinUser *user;
@end
