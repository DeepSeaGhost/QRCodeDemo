//
//  PYHScanCodeVC.m
//  Created by reset on 2018/7/19.

#import "PYHScanCodeVC.h"
#import "PYHFilterSupport.h"
#define kScanWH (CGRectGetWidth(self.view.frame)/6)

@interface PYHScanCodeVC ()

@property (nonatomic, strong) PYHFilterSupport *support;
@property (nonatomic, strong) CAShapeLayer *scanLineLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation PYHScanCodeVC
- (PYHFilterSupport *)support {
    if (!_support) {
        _support = [[PYHFilterSupport alloc]init];
    }
    return _support;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) wself = self;
    [self.support scanCodeWithView:self.view condeInfo:^(NSString *codeInfo) {
        [wself stopDisplay];
        [PYHFilterSupport alertWithPresendVC:self title:nil message:codeInfo preferredStyle:UIAlertControllerStyleAlert isCancel:NO actions:@[@"确定"] blocks:@[^{
            [wself.support startScan];
            [wself runDisplay];
        }]];
    }];
    [self.view addSubview:self.maskView];
}


#pragma mark - load UI
- (UIView *)maskView {
    UIView *maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

    //蒙面
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kScanWH * 2));
    CGPathAddRect(path, nil, CGRectMake(0, kScanWH * 2, kScanWH, kScanWH * 4));
    CGPathAddRect(path, nil, CGRectMake(0, kScanWH * 6, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kScanWH * 6));
    CGPathAddRect(path, nil, CGRectMake(kScanWH * 5, kScanWH * 2, kScanWH, kScanWH * 4));
    maskLayer.path = path;
    maskView.layer.mask = maskLayer;
    
    //边角
    CGFloat lineW = 2;
    for (int i = 0; i < 4; i ++) {
        CAShapeLayer *lineLayer = [[CAShapeLayer alloc]init];
        lineLayer.frame = CGRectMake(kScanWH - lineW, 2 * kScanWH - lineW, 25, 25);
        CGMutablePathRef linePath = CGPathCreateMutable();
        CGPathMoveToPoint(linePath, nil, 1, 24);
        CGPathAddLineToPoint(linePath, nil, 1, 1);
        CGPathAddLineToPoint(linePath, nil, 24, 1);
        lineLayer.path = CGPathCreateCopyByStrokingPath(linePath, nil, lineW, kCGLineCapButt, kCGLineJoinRound, 2);
        lineLayer.fillColor = [[UIColor whiteColor] CGColor];
        
        int number = i == 2 ? 3 : (i == 3 ? 2 : i);
        CGAffineTransform transform = CGAffineTransformTranslate(lineLayer.affineTransform,(4 * kScanWH - 23 + lineW) * (i % 2), (4 * kScanWH - 23 + lineW) * (i / 2));
        transform = CGAffineTransformRotate(transform,M_PI_2 * number);
        [lineLayer setAffineTransform:transform];
        
        [maskView.layer addSublayer:lineLayer];
    }
    
    //扫描线
    self.scanLineLayer = [[CAShapeLayer alloc]init];
    self.scanLineLayer.frame = CGRectMake(kScanWH + kScanWH/2, 2 * kScanWH + 30, 3 * kScanWH, 2);
    self.scanLineLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    [self.view.layer addSublayer:self.scanLineLayer];
    [self runDisplay];
    
    return maskView;
}

- (void)stopDisplay {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
}
- (void)runDisplay {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(display)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)display {
    CGRect frame = self.scanLineLayer.frame;
    frame.origin.y += 1;
    if (frame.origin.y >= (6 * kScanWH - 30)) {
        frame.origin.y = 2 * kScanWH + 30;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.scanLineLayer.frame = frame;
    [CATransaction commit];
}

- (void)dealloc {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
