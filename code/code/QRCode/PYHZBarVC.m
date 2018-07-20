//
//  PYHZBarVC.m
//  Created by reset on 2018/7/19.

#import "PYHZBarVC.h"
#import "ZBarSDK.h"
#import "PYHFilterSupport.h"

@interface PYHZBarVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation PYHZBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CATextLayer *textLayer = [[CATextLayer alloc]init];
    textLayer.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) / 2, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) / 2);
    textLayer.string = @"获取code";
    textLayer.fontSize = 20.f;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.truncationMode = kCATruncationMiddle;
    [self.view.layer addSublayer:textLayer];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ZBarReaderController *imagePC = [[ZBarReaderController alloc]init];
    imagePC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePC.delegate = self;
    [self presentViewController:imagePC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@",info);
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSArray *symbols = info[@"ZBarReaderControllerResults"];
    if (symbols.count) {
        NSString *symbolString = @"";
        for (ZBarSymbol *symbol in symbols) {
            symbolString = [symbolString stringByAppendingFormat:@"\nCode:%@",symbol.data];
        }
        [PYHFilterSupport alertWithPresendVC:self title:nil message:symbolString preferredStyle:UIAlertControllerStyleAlert isCancel:NO actions:@[@"确定"] blocks:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
