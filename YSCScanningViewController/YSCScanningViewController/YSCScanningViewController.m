//
//  YSCScanningViewController.m
//  KQ
//
//  Created by yangshengchao on 15/3/27.
//  Copyright (c) 2015年 yangshengchao. All rights reserved.
//

#import "YSCScanningViewController.h"
#import "ZXingObjC.h"
#import "UIView+Addition.h"

#define XIB_WIDTH               640.0f
#define SCREEN_WIDTH            ([UIScreen mainScreen].bounds.size.width) //屏幕的宽度(point)
#define SCREEN_HEIGHT           ([UIScreen mainScreen].bounds.size.height)//屏幕的高度(point)
#define AUTOLAYOUT_SCALE                (SCREEN_WIDTH / XIB_WIDTH)
#define SCREEN_WIDTH_SCALE              (SCREEN_WIDTH / AUTOLAYOUT_SCALE)
#define SCREEN_HEIGHT_SCALE             (SCREEN_HEIGHT / AUTOLAYOUT_SCALE)

#define RGB(r, g, b)                    [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f]
#define RGBA(r, g, b, a)                [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a]

#define UseScanningType     0       //0-使用ZXing(TODO:识别不准确，暂时没找到原因！)  1-使用系统自带

@interface YSCScanningViewController () <AVCaptureMetadataOutputObjectsDelegate, ZXCaptureDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) AVCaptureSession *session;
@property (assign, nonatomic) NSInteger num;
@property (assign, nonatomic) BOOL isMovingUp;      //指示条是否正在向上移动
@property (assign, nonatomic) BOOL isRecognizing;   //是否正在识别中

@property (weak, nonatomic) IBOutlet UIView *scanningView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanningLineTop;//用于调整扫描线位置

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *frameViews;
@property (nonatomic, strong) ZXCapture *capture;

@end

@implementation YSCScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view resetFontSizeOfView];
    [self.view resetConstraintOfView];
    
    [self initSubviews];
    
    //以下两种方法任选其一都可以
#if UseScanningType
    [self initScanningUseSystem];   //速度较慢
#else
    [self initScanningUseZXing];  //速度很快!!!
#endif
}

- (void)initSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    self.scanningView.backgroundColor = [UIColor clearColor];
    self.isMovingUp = NO;
    self.num = 0;
    
    //TODO:暂时取消动态扫描
//    WeakSelfType blockSelf = self;
//    self.timer = [NSTimer bk_scheduledTimerWithTimeInterval:.01 block:^(NSTimer *timer) {
//        if (NO == blockSelf.isMovingUp) {
//            blockSelf.num++;
//            if (blockSelf.scanningLineTop.constant == AUTOLAYOUT_LENGTH(540)) {
//                blockSelf.isMovingUp = YES;
//            }
//        }
//        else {
//            blockSelf.num--;
//            if (blockSelf.num == 0) {
//                blockSelf.isMovingUp = NO;
//            }
//        }
//        blockSelf.scanningLineTop.constant = AUTOLAYOUT_LENGTH(2 * blockSelf.num);
//    } repeats:YES];
    
    for (UIView *view in self.frameViews) {
        view.backgroundColor = RGBA(10, 10, 10, 0.5);
    }
}

//调用系统自带的条码识别功能
- (void)initScanningUseSystem {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    // 条码类型
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code];
    
    //>>>>>>>>>>>>>>>>>>>>>设置扫描区域>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //注意：1. rectOfInterest是相对于横屏的rect，即x->y  width->height
    //     2. 取值范围0~1.0
    CGRect rect = [self.view convertRect:self.scanningView.frame fromView:self.scanningView.superview];
    output.rectOfInterest = CGRectMake(rect.origin.y / SCREEN_HEIGHT_SCALE,
                                       rect.origin.x / SCREEN_WIDTH_SCALE,
                                       rect.size.width / SCREEN_HEIGHT_SCALE,
                                       rect.size.height / SCREEN_WIDTH_SCALE);
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    // Preview
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view.layer insertSublayer:previewLayer atIndex:0];
}

//调用zxing条码识别功能
- (void)initScanningUseZXing {
    self.capture = [[ZXCapture alloc] init];
    self.capture.delegate = self;
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0;//先旋转90度，然后就不是横屏的坐标了！
    
    //>>>>>>>>>>>>>>>>>>>>>设置扫描区域>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //注意：1. rectOfInterest是相对于横屏的rect，即x->y  width->height
    //     2. 取值范围0~1.0
    CGRect rect = [self.view convertRect:self.scanningView.frame fromView:self.scanningView.superview];
    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(rect.size.width / SCREEN_WIDTH_SCALE, rect.size.height / SCREEN_HEIGHT_SCALE);
    self.capture.scanRect = CGRectApplyAffineTransform(rect, captureSizeTransform);
    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    self.capture.layer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view.layer insertSublayer:self.capture.layer atIndex:0];
}

- (void)startScanning {
    if (self.session) {
        [self.session startRunning];
    }
    if (self.capture) {
        [self.capture start];
    }
    if (self.timer) {
        self.timer.fireDate = [NSDate distantPast];
    }
}
- (void)stopScanning {
    if (self.session) {
        [self.session stopRunning];
    }
    if (self.capture) {
        [self.capture stop];
    }
    if (self.timer) {
        self.timer.fireDate = [NSDate distantFuture];
    }
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (YES == self.isRecognizing) {
        return;
    }
    self.isRecognizing = YES;
    NSString *barCode = nil;
    if ([metadataObjects count] >0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        barCode = metadataObject.stringValue;
    }
    
    if (nil == barCode) {
        self.isRecognizing = NO;
        NSLog(@"scanning failed!");
        return;
    }
    [self stopScanning];
}

#pragma mark - ZXCaptureDelegate Methods
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (YES == self.isRecognizing) {
        return;
    }
    self.isRecognizing = YES;
    if ( nil == result) {
        self.isRecognizing = NO;
        NSLog(@"scanning failed!");
        return;
    }
    [self stopScanning];
}
@end
