//
//  ShowTimeViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/14.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ShowTimeViewController.h"
#import "ALinGPUBeautifyFilter.h"
#import "ALinH264Encoder.h"
#import <AVFoundation/AVFoundation.h>
#import <GPUImage.h>

#define h264outputWidth 1280
#define h264outputHeight 720

@interface ShowTimeViewController () <GPUImageVideoCameraDelegate>
{
    ALinH264Encoder *_h264Encoder;
}
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *beautifulBtn;
@property (nonatomic, strong) GPUImageMovieWriter *writer;
@end

@implementation ShowTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup{
    self.beautifulBtn.layer.cornerRadius = self.beautifulBtn.height * 0.5;
    self.beautifulBtn.layer.masksToBounds = YES;
    
    // 开启前置摄像头的720
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.delegate = self;
    // 设置前置的时候不是镜像
    self.videoCamera.horizontallyMirrorRearFacingCamera = YES;
    [self.videoCamera addAudioInputsAndOutputs]; // 添加麦克风/声音的输出输入设备
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.center = self.view.center;
    [self.view insertSubview:self.filterView atIndex:0];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    // 默认开启美颜效果
    [self openBeautiful];
    
    _h264Encoder = [ALinH264Encoder alloc];
    [_h264Encoder initWithConfiguration];
    [_h264Encoder initEncode:h264outputWidth height:h264outputHeight];
}
// 关闭直播
- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 开启/关闭美颜相机
- (IBAction)beautiful:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (!sender.selected) { // 开启了美图过滤
        [self openBeautiful];
    }else{ // 关闭美图过滤
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.filterView];
    }
}

// 开启美颜效果
- (void)openBeautiful
{
    [self.videoCamera removeAllTargets];
    ALinGPUBeautifyFilter *beautifyFilter = [[ALinGPUBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
}

// 切换前置/后置摄像头
- (IBAction)switchCamare:(UIButton *)sender {
    [self.videoCamera rotateCamera];
    NSLog(@"切换前置/后置摄像头");
}

#pragma mark - <GPUImageVideoCameraDelegate>
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 获取当前的信息
    CVPixelBufferRef bufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 获取视频宽度
    size_t width =  CVPixelBufferGetWidth(bufferRef);
    size_t height = CVPixelBufferGetHeight(bufferRef);
    NSLog(@"%ld %ld", width, height);
    NSLog(@"%@", [self.videoCamera videoCaptureConnection].audioChannels);
    [_h264Encoder encode:sampleBuffer];
}

@end
