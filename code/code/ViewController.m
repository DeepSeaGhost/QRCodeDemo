//
//  ViewController.m
//  code
//
//  Created by reset on 2018/7/20.
//  Copyright © 2018年 ghost. All rights reserved.
//

#import "ViewController.h"
#import "PYHCodeGeneratorVC.h"
#import "PYHScanCodeVC.h"
#import "PYHZBarVC.h"
#define kH ((CGRectGetHeight(self.view.frame)-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height) / 3)

@interface ViewController ()

@property (nonatomic, strong) UIButton *makeBT;
@property (nonatomic, strong) UIButton *parsBT;
@property (nonatomic, strong) UIButton *barBT;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self baseConfig];
    [self configUI];
}
- (void)baseConfig {
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}
- (void)configUI {
    [self.view addSubview:self.makeBT];
    [self.view addSubview:self.parsBT];
    [self.view addSubview:self.barBT];
}


#pragma mark - handlean
- (void)make {
    PYHCodeGeneratorVC *vc = [PYHCodeGeneratorVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)parse {
    PYHScanCodeVC *vc = [PYHScanCodeVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)bar {
    PYHZBarVC *vc = [PYHZBarVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - lazy loading
- (UIButton *)makeBT {
    if (!_makeBT) {
        _makeBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kH)];
        _makeBT.backgroundColor = [UIColor grayColor];
        [_makeBT setTitle:@"制作二维码/条码" forState:UIControlStateNormal];
        [_makeBT addTarget:self action:@selector(make) forControlEvents:UIControlEventTouchUpInside];
    }
    return _makeBT;
}
- (UIButton *)parsBT {
    if (!_parsBT) {
        _parsBT = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.makeBT.frame), CGRectGetWidth(self.view.frame), kH)];
        _parsBT.backgroundColor = [UIColor lightGrayColor];
        [_parsBT setTitle:@"解析二维码/条码" forState:UIControlStateNormal];
        [_parsBT addTarget:self action:@selector(parse) forControlEvents:UIControlEventTouchUpInside];
    }
    return _parsBT;
}
- (UIButton *)barBT {
    if (!_barBT) {
        _barBT = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.parsBT.frame), CGRectGetWidth(self.view.frame), kH)];
        _barBT.backgroundColor = [UIColor grayColor];
        [_barBT setTitle:@"ZBarSDK" forState:UIControlStateNormal];
        [_barBT addTarget:self action:@selector(bar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barBT;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
