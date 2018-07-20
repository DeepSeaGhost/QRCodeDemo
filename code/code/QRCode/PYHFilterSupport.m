//
//  PYHFilterSupport.m
//  Created by reset on 2018/7/19.

#import "PYHFilterSupport.h"
#import <AVFoundation/AVFoundation.h>
@interface PYHFilterSupport ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic, copy) void(^codeBlock)(NSString *codeInfo);
@end

@implementation PYHFilterSupport

#pragma mark - 查看所有滤镜类型
+ (void)logAllFiltertype {
    //kCICategoryFilterGenerator iOS9  other iOS5
    NSArray *arr = @[kCICategoryGeometryAdjustment,kCICategoryCompositeOperation,kCICategoryHalftoneEffect,kCICategoryColorAdjustment,kCICategoryColorEffect,kCICategoryTransition,kCICategoryGenerator,kCICategoryReduction,kCICategoryGradient,kCICategoryStylize,kCICategorySharpen,kCICategoryBlur,kCICategoryVideo,kCICategoryStillImage,kCICategoryInterlaced,kCICategoryInterlaced,kCICategoryNonSquarePixels,kCICategoryHighDynamicRange,kCICategoryBuiltIn,kCICategoryFilterGenerator];
    [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr = [CIFilter filterNamesInCategory:obj];
        NSLog(@"%@-%@",obj,arr);
    }];
}

#pragma mark - 生成指定类型码
+ (UIImage *)outputImageWithData:(id)data filterName:(NSString *)filterName {
    if ([filterName isEqualToString:@"CICode128BarcodeGenerator"] && ![self isASCII:data]) return nil;
    // 1.创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:filterName];
    // 2.恢复默认设置
    [filter setDefaults];
    // 3.设置数据
    NSData *infoData;
    if ([data isKindOfClass:[UIImage class]]) {
        infoData = UIImagePNGRepresentation((UIImage *)data);
    }else if([data isKindOfClass:[NSString class]]) {
        infoData = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    }
    [filter setValue:infoData forKey:@"inputMessage"];
    // 4.生成二维码
    CIImage *outputImage = [filter outputImage];
    return [self createNonInterpolatedUIIamgeFormCIImage:outputImage withSize:300.f];
}
#pragma mark 获取清晰二维码
+ (UIImage *)createNonInterpolatedUIIamgeFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    
    // 1.创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextRef bitmapRef = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Host | CGImageGetAlphaInfo(bitmapImage));
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


#pragma mark - 扫描code
- (void)scanCodeWithView:(UIView *)view condeInfo:(void(^)(NSString *codeInfo))block {
    self.codeBlock = block;
    CGFloat scanWH = CGRectGetWidth(view.frame) / 6;
    
    // 1. 创建捕捉会话
    self.session = [[AVCaptureSession alloc] init];
    
    // 2. 添加输入设备(数据从摄像头输入)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [self.session addInput:input];
    
    // 3. 添加输出数据接口
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    output.rectOfInterest = CGRectMake((2 * scanWH) /CGRectGetHeight(view.frame), scanWH / CGRectGetWidth(view.frame), (4 * scanWH)/CGRectGetHeight(view.frame), (4 * scanWH)/CGRectGetWidth(view.frame));
    // 设置输出接口代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    // 3.1 设置输入元数据的类型(类型是二维码数据)
    // 注意，这里必须设置在addOutput后面，否则会报错
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode]];
    /*
     AVMetadataObjectTypeUPCECode
     AVMetadataObjectTypeCode39Code
     AVMetadataObjectTypeCode39Mod43Code
     AVMetadataObjectTypeEAN13Code
     AVMetadataObjectTypeEAN8Code
     AVMetadataObjectTypeCode93Code
     AVMetadataObjectTypeCode128Code
     AVMetadataObjectTypePDF417Code
     AVMetadataObjectTypeQRCode
     AVMetadataObjectTypeAztecCode
     AVMetadataObjectTypeInterleaved2of5Code
     AVMetadataObjectTypeITF14Code
     AVMetadataObjectTypeDataMatrixCode
     */
    
    
    
    // 4.添加扫描图层
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layer.frame = view.bounds;
    [view.layer addSublayer:self.layer];
    
    // 5. 开始扫描
    [self startScan];
}
- (void)startScan {
    [self.session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        // 扫描到了数据
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        NSLog(@"%@",object.stringValue);
        if (self.codeBlock) self.codeBlock(object.stringValue);
        
        [self.session stopRunning];// 停止扫描
    }else{
        NSLog(@"没有扫描到数据");
    }
}

#pragma mark - 长按识别二维码
+ (void)longPressScanCode:(UIImage *)image block:(void(^)(id obj))block{
    //1.初始化扫描仪，设置设别类型和识别质量
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //2.扫描获取的特征组
    NSArray*features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if(features.count > 0) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        if (block) block(scannedResult);
    }else {
        if (block) block(nil);
    }
}

#pragma mark - alert
+ (void)alertWithPresendVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style isCancel:(BOOL)isCancel actions:(NSArray<NSString *> *)actions blocks:(NSArray<void (^)(UIAlertAction * _Nonnull action)> *)actionBlocks {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    
    if (isCancel) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancel];
    }
    
    if (actions) {
        for (int i = 0; i < actions.count; i ++) {
            NSString *title = actions[i];
            void (^block)(UIAlertAction * _Nonnull action) = actionBlocks ? (i > actionBlocks.count - 1 ? nil : actionBlocks[i]) : nil;
            UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:block];
            [alertVC addAction:action];
        }
    }
    
    [vc presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 全部ascii
+ (BOOL)isASCII:(id)codeInfo {
    if (![codeInfo isKindOfClass:[NSString class]]) return NO;
    NSInteger strlen = [codeInfo length];
    NSInteger datalen = [[codeInfo dataUsingEncoding:NSUTF8StringEncoding] length];
    return strlen == datalen;

}
@end
