//
//  PICViewController.m
//  TextDemo
//
//  Created by 孙理涛 on 16/5/17.
//  Copyright © 2016年 新浪视觉. All rights reserved.
//

#import "PICViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageViewController.h"

@interface PICViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureSession *captureSession;
    AVCaptureDevice *captureDevice;
    AVCaptureVideoPreviewLayer *previewLayer;
    UIImage *resultImage;
    BOOL isStart;
}

@end

@implementation PICViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [captureSession startRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initDeviece];
}

/**
 *  初始化拍摄环境
 */
- (void)initDeviece{
    isStart = NO;
    [self isStartTrue];
    
    captureSession = [[AVCaptureSession alloc]init];
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    NSArray *devices = [[NSArray alloc]init];
    devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                captureDevice = device;
                if (captureDevice != nil) {
                    NSLog(@"Capture Device found");
                    [self beginSession];
                }
            }
        }
    }
}

/**
 *  相机是否开始进行拍摄
 */
-(void) isStartTrue {
    isStart = YES;
}

/**
 *  开始进行拍摄
 */
-(void)beginSession {
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:nil];
    [captureSession addInput:captureDeviceInput];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t cameraQueue;
    cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:cameraQueue];
    NSDictionary *videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],kCVPixelBufferPixelFormatTypeKey, nil];
    output.videoSettings = videoSettings;
    [captureSession addOutput:output];
    previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 64, self.view.bounds.size.width, 300);
    [self.view.layer addSublayer:previewLayer];
    [captureSession startRunning];
    
}

#pragma mark  AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (isStart) {
        resultImage = [[UIImage alloc] init];
        resultImage = [self sampleBufferToImage:sampleBuffer];
        CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
        CIImage *ciImage = [[CIImage alloc]init];
        ciImage = [CIImage imageWithCGImage:resultImage.CGImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        NSArray *results = [detector featuresInImage:ciImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation]];
        if ([results count] == 0) {
            NSLog(@"未检测到人脸");
        }else{
            NSLog(@"检测到人脸");
        }
    }
}

/**
 *  从缓存中取得样本图片进行处理
 *
 *  @param sampleBuffer 缓存样本
 *
 *  @return 处理过的图片
 */
-(UIImage *)sampleBufferToImage:(CMSampleBufferRef)sampleBuffer{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    UIImage *result = [[UIImage alloc] initWithCGImage:videoImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    CGImageRelease(videoImage);
    
    return result;
    
}

@end
