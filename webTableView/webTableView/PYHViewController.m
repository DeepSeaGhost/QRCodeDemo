//
//  PYHViewController.m
//  Created by reset on 2018/6/8.

#import "PYHViewController.h"
#import "PYHWebListViewController.h"

@interface PYHViewController ()

@end

@implementation PYHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    PYHWebListViewController *vc = [[PYHWebListViewController alloc]initWithWebUrl:@"http://www.miaopai.com/u/paike_8o7ugjvf5c" comments:nil];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
