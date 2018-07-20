//
//  PYHCodeGeneratorVC.m
//  Created by reset on 2018/7/19.

#import "PYHCodeGeneratorVC.h"
#import "PYHFilterSupport.h"
#define kItemW (CGRectGetWidth(self.view.frame)/6)

@interface PYHCodeGeneratorVC ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textV;
@property (nonatomic, strong) UIImageView *codeIV;
@end

@implementation PYHCodeGeneratorVC {
    PYHCodeType _codeType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configUI];
    [PYHFilterSupport logAllFiltertype];
}

#pragma mark - handle
- (void)go:(UIButton *)bt {
    switch (bt.tag - 1000) {
        case 0:
            self.codeIV.image = [PYHFilterSupport outputImageWithData:self.textV.text filterName:@"CIQRCodeGenerator"];
            _codeType = PYHCodeTypeQRCode;
            break;
        case 1:
            self.codeIV.image = [PYHFilterSupport outputImageWithData:self.textV.text filterName:@"CICode128BarcodeGenerator"];
            _codeType = PYHCodeType128BarCode;
            break;
        case 2:
            self.codeIV.image = [PYHFilterSupport outputImageWithData:self.textV.text filterName:@"CIPDF417BarcodeGenerator"];
            _codeType = PYHCodeTypePDF147BarCode;
            break;
        default:
            break;
    }
    if (self.codeIV.image) {
        self.codeIV.hidden = NO;
    }
}
- (void)scanCode:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [PYHFilterSupport alertWithPresendVC:self title:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet isCancel:YES actions:@[@"长按识别二维码"] blocks:@[^(UIAlertAction *action){
            [PYHFilterSupport longPressScanCode:[(UIImageView *)longPress.view image]  block:^(id obj) {
                if (obj) {
                    //解析成功
                    [PYHFilterSupport alertWithPresendVC:self title:nil message:[@"code:" stringByAppendingString:(NSString *)obj] preferredStyle:UIAlertControllerStyleAlert isCancel:NO actions:@[@"确定"] blocks:nil];
                }else {
                    //解析失败
                    [PYHFilterSupport alertWithPresendVC:self title:@"识别失败" message:nil preferredStyle:UIAlertControllerStyleAlert isCancel:NO actions:@[@"确定"] blocks:nil];
                }
            }];
        }]];
    }
}

#pragma mark - textViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - load UI
- (UIImageView *)codeIV {
    if (!_codeIV) {
        _codeIV = [[UIImageView alloc]initWithFrame:self.textV.frame];
        _codeIV.userInteractionEnabled = YES;
        _codeIV.hidden = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(scanCode:)];
        [_codeIV addGestureRecognizer:longPress];
    }
    return _codeIV;
}
- (UITextView *)textV {
    if (!_textV) {
        _textV = [[UITextView alloc]initWithFrame:CGRectMake(kItemW, kItemW, kItemW * 4, kItemW * 4)];
        _textV.layer.borderWidth = 1.f;
        _textV.layer.borderColor = [UIColor blueColor].CGColor;
        _textV.returnKeyType = UIReturnKeyDone;
        _textV.delegate = self;
    }
    return _textV;
}
- (void)configUI {
    [self.view addSubview:self.textV];
    [self.view addSubview:self.codeIV];
    NSArray *titles = @[@"QRCode",@"128BarCode",@"PDF417BarCode"];
    for (int i = 0; i < 3; i ++) {
        UIButton *bt = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/3 * i, CGRectGetMaxY(self.textV.frame) + 2 * kItemW, kItemW * 2, 44.f)];
        [bt setTitle:titles[i] forState:UIControlStateNormal];
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        bt.titleLabel.font = [UIFont systemFontOfSize:14];
        bt.tag = 1000 + i;
        [bt addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end


