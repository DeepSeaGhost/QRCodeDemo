//
//  PYHFilterSupport.h
//  Created by reset on 2018/7/19.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PYHCodeType) {
    PYHCodeTypeQRCode  = 0,
    PYHCodeType128BarCode     = 1,
    PYHCodeTypePDF147BarCode  = 2,
};

@interface PYHFilterSupport : NSObject

///查看所有滤镜类型
+ (void)logAllFiltertype;

///生成指定类型码
+ (UIImage *)outputImageWithData:(id)data filterName:(NSString *)filterName;

///扫描code
- (void)scanCodeWithView:(UIView *)view condeInfo:(void(^)(NSString *codeInfo))block;
- (void)startScan;


///长按识别二维码
+ (void)longPressScanCode:(UIImage *)image block:(void(^)(id obj))block;

///alert
+ (void)alertWithPresendVC:(UIViewController *)vc title:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style isCancel:(BOOL)isCancel actions:(NSArray <NSString *>*)actions blocks:(NSArray <void(^)(void)>*)actionBlocks;
@end
