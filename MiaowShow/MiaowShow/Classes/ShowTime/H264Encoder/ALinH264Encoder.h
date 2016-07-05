//
//  ALinH264Encoder.h
//  MiaowShow
//
//  Created by ALin on 16/7/4.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

//@protocol ALinH264EncoderDelegate <NSObject>
//
//- (void)gotSps:(NSData*)sps pps:(NSData*)pps;
//- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame;
//
//@end

@interface ALinH264Encoder : NSObject
// 初始化基本配置
- (void) initWithConfiguration;
- (void) initEncode:(int)width  height:(int)height;
- (void) encode:(CMSampleBufferRef)sampleBuffer;

//@property (weak, nonatomic) id<ALinH264EncoderDelegate> delegate;
@end
