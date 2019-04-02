//
//  ViewController.m
//  大小锅稽核
//
//  Created by yesdgq on 2019/4/1.
//  Copyright © 2019 Yesdgq. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+Addition.h"
#import "ViewControllerA.h"

#define kMainScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kMainScreenHeight   [[UIScreen mainScreen] bounds].size.height

#define MAXVIDEOTIME 70 // 视频最大时间
#define MINVIDEOTIME 60 // 视频最小时间
#define TIMER_REPEAT_INTERVAL 0.1 // Timer repeat 时间
#define LOVELYBABY_VIDEO_FOLDER @"mengwa"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession; // 媒体捕获会话
@property (nonatomic, strong) AVCaptureDeviceInput *videoCaptureDeviceInput; // 视频设备输入数据管理对象
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureDeviceInput; // 音频设备输入数据管理对象
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput; // 输出数据管理对象
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; // 相机拍摄预览图层
@property (nonatomic, strong)  UIView *viewContainer; // 视频拍摄视图容器
@property (nonatomic, strong) UIImageView *focusCursor; // 聚焦光标

@end

@implementation ViewController

{
    UIView *progressView; // 进度条;
    NSTimer *countTimer; // 计时器
    UIButton *finishBtn; // 录制结束按钮
    float currentTime; // 当前视频长度
    float progressStep; // 进度条每次变长的最小单位
    
    float videoLayerWidth; // 镜头宽
    float videoLayerHeight; // 镜头高
    float videoLayerHWRate; // 高，宽比
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //    UIImagePickerController *profilePicker = [[UIImagePickerController alloc] init];
    //    profilePicker.modalPresentationStyle = UIModalPresentationPopover;
    //    profilePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    profilePicker.allowsEditing = NO;
    //    profilePicker.delegate = self;
    //    profilePicker.preferredContentSize = CGSizeMake(512.f, 512.f);
    //    profilePicker.popoverPresentationController.sourceView = self.view;
    //
    //    [self presentViewController:profilePicker animated:YES completion:nil];
    
    
    
    //    // 0.视频拍摄窗口设置
    //    videoLayerWidth = kMainScreenWidth;
    //    videoLayerHeight = kMainScreenWidth;
    //    videoLayerHWRate = videoLayerHeight / videoLayerWidth;
    //    progressStep = kMainScreenWidth * TIMER_REPEAT_INTERVAL / MAXVIDEOTIME;
    //
    //    // 1.导航栏按钮
    //
    //    // 2.初始化摄像机
    //    [self initializeCameraConfiguration];
    //    // 3.录制按钮
    ////    [self addVideoRecordBtnView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 50)];
    [button setTitle:@"下一步" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)nextStep:(UIButton *)sender {
    
    ViewControllerA *aVC = [[ViewControllerA alloc] init];
    [self.navigationController pushViewController:aVC animated:YES];
    
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
//
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    UIImage *mediaType = info[@"UIImagePickerControllerMediaType"];
    UIImage *mediaData = info[@"UIImagePickerControllerMediaMetadata"];
}



// 录制视频按钮
- (void)addVideoRecordBtnView
{
    UIView *btnBG = [[UIView alloc] init];
    btnBG.backgroundColor = [UIColor blackColor];
    btnBG.alpha = 0.8f;
    [self.view addSubview:btnBG];
    //    [btnBG mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.bottom.right.equalTo(self.view);
    //        make.top.equalTo(_viewContainer.mas_bottom);
    //        //make.height.equalTo(@150);
    //    }];
    
    // 录制按钮
    UIButton *videoRecordBtn = [[UIButton alloc] init];
    [videoRecordBtn addTarget:self action:@selector(beginVideoRecording) forControlEvents:UIControlEventTouchDown];
    [videoRecordBtn addTarget:self action:@selector(stopVideoRecording) forControlEvents:UIControlEventTouchUpInside];
    [videoRecordBtn addTarget:self action:@selector(stopVideoRecording) forControlEvents:UIControlEventTouchDragExit];
    [videoRecordBtn setBackgroundImage:[UIImage imageNamed:@"VideoRecordBtnBG"] forState:UIControlStateNormal];
    [btnBG addSubview:videoRecordBtn];
    //    [videoRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.center.equalTo(btnBG);
    //        make.size.mas_equalTo(CGSizeMake(80, 80));
    //    }];
    
    // 录制完成按钮
    finishBtn = [[UIButton alloc] init];
    finishBtn.alpha = 1.f;
    finishBtn.hidden = YES;
    [finishBtn addTarget:self action:@selector(videoRecordingFinish) forControlEvents:UIControlEventTouchUpInside];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"VideoRecordingFinish"] forState:UIControlStateNormal];
    [btnBG addSubview:finishBtn];
    //    [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(btnBG.mas_right).offset(-50);
    //        make.centerY.equalTo(btnBG);
    //        make.size.mas_equalTo(CGSizeMake(30, 30));
    //    }];
}




// 初始化摄像机
- (void)initializeCameraConfiguration
{
    // 1.创建视频拍摄总容器
    self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, videoLayerWidth, videoLayerHeight)];
    [self.view addSubview:_viewContainer];
    
    // 2.创建会话 (AVCaptureSession) 对象。
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        // 设置会话的 sessionPreset 属性, 这个属性影响视频的分辨率
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    // 3.使用AVCaptureDevice的静态方法获得需要使用的设备 获取摄像头输入设备， 创建 AVCaptureDeviceInput 对象
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    
    // 添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 4.利用输入设备AVCaptureDevice初始化AVCaptureDeviceInput对象。
    NSError *error;
    _videoCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error]; // 视频输入对象
    if (error) {
        NSLog(@"---- 取得设备输入对象时出错 ------ %@",error);
        return;
    }
    _audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error]; // 音频输入对象
    if (error) {
        NSLog(@"取得设备输入对象时出错 ------ %@",error);
        return;
    }
    
    // 5.初始化输出数据管理对象，如果要拍照就初始化AVCaptureStillImageOutput对象；如果拍摄视频就初始化AVCaptureMovieFileOutput对象
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    
    // 6.将视音频数据输入对象AVCcaptureFileOutput（对应子类）添加到媒体会话管理对象AVCaptureSession中
    if ([_captureSession canAddInput:_videoCaptureDeviceInput]) {
        [_captureSession addInput:_videoCaptureDeviceInput]; // 视频
    }
    if ([_captureSession canAddInput:_audioCaptureDeviceInput]) {
        [_captureSession addInput:_audioCaptureDeviceInput]; // 音频
        // 建立连接
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        // 标识视频录入时稳定音频流的接受，这里设置为自动
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    // 7.创建视频预览图层AVCaptureVideoPreviewLayer并指定媒体会话，添加图层到显示容器中，调用AVCaptureSession的startRuning方法开始捕获。
    // 通过会话 (AVCaptureSession) 创建预览层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    // 显示在视图表面的图层
    CALayer *layer = self.viewContainer.layer;
    layer.masksToBounds = true;
    
    _captureVideoPreviewLayer.frame = layer.bounds;
    _captureVideoPreviewLayer.masksToBounds = true;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 填充模式
    [layer addSublayer:_captureVideoPreviewLayer];
    
    // 让会话（AVCaptureSession）勾搭好输入输出，然后把视图渲染到预览层上
    [_captureSession startRunning];
    
    // 8.添加聚焦光标
    self.focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_focusCursor setImage:[UIImage imageNamed:@"FocusCursor"]];
    _focusCursor.alpha = 0.f;
    [_viewContainer addSubview:_focusCursor];
    [self addFocusTapGenstureRecognizer];
    
    // 9.进度条
    progressView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
    progressView.backgroundColor = [UIColor colorWithHex:@"#24D609"];
    [self.viewContainer addSubview:progressView];
    //    UIProgressView *progressView2 = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 0)];
    //    [self.viewContainer addSubview:progressView2];
    //    progressView2.tintColor = [UIColor colorWithHex:@"0xffc738"];
    //    progressView2.trackTintColor = [UIColor redColor];
    //    self.progressView = progressView2;
    
    // 10.将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    
    
    // 取消视频拍摄
    //    [self.caputureMovieFileOutput stopRecording];
    //    [self.captureSession stopRunning];
    //    [self completeHandle];
}

// 取得指定位置的摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

// 添加tap手势
- (void)addFocusTapGenstureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusTap:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}

- (void)focusTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.viewContainer];
    // 将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)setFocusCursorWithPoint:(CGPoint)point
{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}

// 设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

// 改变设备属性的统一操作方法
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange
{
    AVCaptureDevice *captureDevice = [self.videoCaptureDeviceInput device];
    NSError *error;
    // 改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
    } else {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}


@end

