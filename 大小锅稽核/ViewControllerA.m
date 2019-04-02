//
//  ViewControllerA.m
//  大小锅稽核
//
//  Created by yesdgq on 2019/4/1.
//  Copyright © 2019 Yesdgq. All rights reserved.
//

#import "ViewControllerA.h"
#import <AVFoundation/AVFoundation.h>

#define kMainScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kMainScreenHeight   [[UIScreen mainScreen] bounds].size.height

@interface ViewControllerA () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate, AVCapturePhotoCaptureDelegate, UIScrollViewDelegate>

// 捕获设备，通常是前置摄像头，后置摄像头，麦克风
@property(nonatomic, strong) AVCaptureDevice *device;
// 输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic, strong) AVCaptureDeviceInput *input;
// 当启动摄像头开始捕获输入
@property(nonatomic, strong) AVCaptureMetadataOutput *output;
// AVCapturePhotoOutput
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;
// 输出设置
@property (nonatomic, strong) AVCapturePhotoSettings *photoImageOutputSetting;
// session：由他把输入输出结合在一起，并开始启动捕获设备
@property(nonatomic, strong) AVCaptureSession *session;
// 图像预览层，实时显示捕获的图像
@property(nonatomic, strong)  AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *PhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, assign) BOOL isflashOn;
@property (nonatomic, strong) UIImage *image;





@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;


@end

@implementation ViewControllerA

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL cameraUseable = [self canUserCamear];
    
    if (cameraUseable) {
        [self initializeCamera];
        [self setupPreLayerView];
    } else {
        return;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)setupPreLayerView {
    
    self.imagesArray = @[@"Car",@"Car"];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.delegate = self;
    CGSize size = CGSizeMake(self.scrollView.bounds.size.width * self.imagesArray.count, 0);
    self.scrollView.contentSize = size;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    // 添加图片
    [self.imagesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageNamed:obj];
        UIImageView *iv = [[UIImageView alloc] initWithImage:image];
        CGRect frame = CGRectZero;
        frame.origin.x = idx * self.scrollView.bounds.size.width;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        iv.frame = frame;
        [self.scrollView addSubview:iv];
    }];
    
    [self.view addSubview:self.scrollView];
    
    // 以下为设置翻页小红点
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    pageControl.frame = CGRectMake(0, 40, self.view.frame.size.width, 30);
    
    pageControl.numberOfPages = [self.imagesArray count];
    // 未选中页面的颜色
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    // 选中页面的颜色
    pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
    self.pageControl = pageControl;
    [self.view insertSubview:self.pageControl aboveSubview:self.scrollView];
    
    // 焦点
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    // 拍照按钮
    _PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _PhotoButton.frame = CGRectMake(kMainScreenWidth / 2.0 - 30, kMainScreenHeight - 100, 60, 60);
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
    [_PhotoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_PhotoButton];
    
    // 取消按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(kMainScreenWidth / 4.0 - 30, kMainScreenHeight - 100, 60, 60);
    [leftButton setTitle:@"重拍" forState:UIControlStateNormal];
    leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(kMainScreenWidth * 3/ 4.0 - 30, kMainScreenHeight-100, 60, 60);
        [rightButton setTitle:@"完成" forState:UIControlStateNormal];
        rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [rightButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightButton];
    
    //    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    _flashButton.frame = CGRectMake(kMainScreenWidth * 3 / 4.0 - 30, kMainScreenHeight - 100, 80, 60);
    //    [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
    //    [_flashButton addTarget:self action:@selector(flashOn) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:_flashButton];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)initializeCamera {
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    // 生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc] init];
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    self.photoImageOutputSetting = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [self.imageOutput setPhotoSettingsForSceneMonitoring:self.photoImageOutputSetting];
    
    // 生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    NSError *error;
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    // 🍺开始启动
    [self.session startRunning];
    
    if ([_device lockForConfiguration:nil]) {
        
        if ([self.imageOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeAuto)]) {
            self.photoImageOutputSetting.flashMode = AVCaptureFlashModeAuto;
            [self.imageOutput setPhotoSettingsForSceneMonitoring:self.photoImageOutputSetting];
        }
        
        // 自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}
- (void)flashOn {
    
    if ([_device lockForConfiguration:nil]) {
        if (_isflashOn) {
            
            if ([self.imageOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOff)]) {
                self.photoImageOutputSetting.flashMode = AVCaptureFlashModeOff;
                [self.imageOutput setPhotoSettingsForSceneMonitoring:self.photoImageOutputSetting];
                _isflashOn = NO;
                [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
            }
            
        } else {
            
            if ([self.imageOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOn)]) {
                self.photoImageOutputSetting.flashMode = AVCaptureFlashModeOn;
                [self.imageOutput setPhotoSettingsForSceneMonitoring:self.photoImageOutputSetting];
                _isflashOn = YES;
                [_flashButton setTitle:@"闪光灯开" forState:UIControlStateNormal];
            }
        }
        
        [_device unlockForConfiguration];
    }
}

- (void)changeCamera {
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
        
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point {
    
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
        
        //[self addScaleAnimationOnView:self.focusView repeatCount:1];
    }
    
    
    
}

// 缩放动画
- (void)addScaleAnimationOnView:(UIView *)animationView repeatCount:(float)repeatCount {
    // 需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@2.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.repeatCount = repeatCount;
    animation.calculationMode = kCAAnimationCubic;
    [animationView.layer addAnimation:animation forKey:@"UserGuide"];
}

#pragma mark - 截取照片

- (void) shutterCamera {
    
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [self.imageOutput capturePhotoWithSettings:outputSettings delegate:self];
    
    //    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    //        if (imageDataSampleBuffer == NULL) {
    //            return;
    //        }
    //        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    //        self.image = [UIImage imageWithData:imageData];
    //        [self.session stopRunning];
    //        [self saveImageToPhotoAlbum:self.image];
    //        self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
    //        [self.view insertSubview:_imageView belowSubview:_PhotoButton];
    //        self.imageView.layer.masksToBounds = YES;
    //        self.imageView.image = _image;
    //        NSLog(@"image size = %@",NSStringFromCGSize(self.image.size));
    //    }];
}

//- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
//
//    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
//    UIImage *image = [UIImage imageWithData:data];
//
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//}

// iOS11 available
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    // 这个就是HEIF(HEIC)的文件数据,直接保存即可
    NSData *data = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:data];
    // 保存图片到相册
    
    
    [self.session stopRunning];
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
    [self.view insertSubview:self.imageView belowSubview:self.scrollView];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.image = image;
    NSLog(@"image size = %@",NSStringFromCGSize(image.size));
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSString *msg = nil ;
    if (error != NULL){
        msg = @"保存图片失败" ;
    } else {
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)cancle {
    [self.imageView removeFromSuperview];
    [self.session startRunning];
}

#pragma mark - 检查相机权限

- (BOOL)canUserCamear {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    } else {
        return YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIScrollViewDelegate

//当图片滑动时会触发方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 关注移动距离（偏移量）
    CGPoint offset = scrollView.contentOffset;
    // 不足0的偏移量 当它为0
    if (offset.x <= 0) {
        offset.x = 0;
        scrollView.contentOffset = offset;
    }
    // round进行四舍五入
    NSUInteger index = round(offset.x / scrollView.frame.size.width);
    // 根据偏移量来计算出当前页是那一页
    self.pageControl.currentPage = index;
    NSLog(@"index---%lu",(unsigned long)index);
}


@end
