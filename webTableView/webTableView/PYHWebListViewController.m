//
//  PYHWebListViewController.m
//  Created by reset on 2018/6/8.

#import "PYHWebListViewController.h"
#import <WebKit/WebKit.h>
#define kWebListW [UIScreen mainScreen].bounds.size.width
#define kWebListH [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height - self.tabBarController.tabBar.frame.size.height

@interface PYHWebListViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIScrollView *baseScrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIWebView *beforeWebView;
@property (nonatomic, strong) WKWebView *afterWebView;

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation PYHWebListViewController {
    NSString *_webUrl;
    NSString *_requestUrl;
    CGFloat _lastWebContentHeight;
    CGFloat _lastTableContentHeight;
}
- (instancetype)initWithWebUrl:(NSString *)webUrl comments:(NSString *)requestUrl; {
    if (self = [super init]) {
        _webUrl = webUrl;
        _requestUrl = requestUrl;
        _lastWebContentHeight = 0;
        _lastTableContentHeight = 0;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
    [self addObserVer];
    [self loadData];
}

#pragma mark - config UI
- (void)configView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11.0, *)) {
        self.baseScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 7.0, *)) {
            self.afterWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.beforeWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.baseScrollView];
    [self.baseScrollView addSubview:self.contentView];
    if (@available(iOS 7.0, *)) {
        [self.contentView addSubview:self.afterWebView];
    }else {
        [self.contentView addSubview:self.beforeWebView];
    }
    [self.contentView addSubview:self.tableView];
}
- (void)addObserVer {
    if (@available(iOS 7.0, *)) {
        [self.afterWebView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }else {
        [self.beforeWebView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObserver {
    if (@available(iOS 7.0, *)) {
        [self.afterWebView removeObserver:self forKeyPath:@"scrollView.contentSize"];
    }else {
        [self.beforeWebView removeObserver:self forKeyPath:@"scrollView.contentSize"];
    }
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}
- (void)loadData {
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:_webUrl]];
    if (@available(iOS 7.0, *)) {
        [self.afterWebView loadRequest:request];
    }else {
        [self.beforeWebView loadRequest:request];
    }
    
}

#pragma mark - observer change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:_tableView]) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self updateContentConfig];
        }
    }else {
        if (@available(iOS 7.0, *)) {
            if ([object isEqual:_afterWebView] && [keyPath isEqualToString:@"scrollView.contentSize"]) {
                [self updateContentConfig];
            }
        }else {
            if ([object isEqual:_beforeWebView] && [keyPath isEqualToString:@"scrollView.contentSize"]) {
                [self updateContentConfig];
            }
        }
    }
}
- (void)updateContentConfig {
    CGFloat tableContentH = self.tableView.contentSize.height;
    CGFloat webContentH = 0;
    if (@available(iOS 7.0, *)) {
        webContentH = self.afterWebView.scrollView.contentSize.height;
    }else {
        webContentH = self.beforeWebView.scrollView.contentSize.height;
    }
    
    if (tableContentH == _lastTableContentHeight && webContentH == _lastWebContentHeight) return;
    _lastTableContentHeight = tableContentH;
    _lastWebContentHeight = webContentH;
    
    NSLog(@"%f%f",tableContentH,webContentH);
    
    self.baseScrollView.contentSize = CGSizeMake(0, webContentH + tableContentH);
    CGFloat newWebH = webContentH > kWebListH ? kWebListH : (webContentH < 0.1f ? 0.1f : webContentH);
    CGFloat newTableH = tableContentH > kWebListH ? kWebListH : tableContentH;
    if (@available(iOS 7.0, *)) {
        self.afterWebView.frame = CGRectMake(0, 0, kWebListW, newWebH);
    }else {
        self.beforeWebView.frame = CGRectMake(0, 0, kWebListW, newWebH);
    }
    self.tableView.frame = CGRectMake(0, newWebH, kWebListW, newTableH);
    self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, kWebListW, newWebH + newTableH);
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _baseScrollView) return;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat tableContentH = self.tableView.contentSize.height;
    CGFloat tableH = self.tableView.bounds.size.height;
    CGFloat webContentH = 0;
    CGFloat webH = 0;
    if (@available(iOS 7.0, *)) {
        webContentH = self.afterWebView.scrollView.contentSize.height;
        webH = self.afterWebView.scrollView.bounds.size.height;
    }else {
        webContentH = self.beforeWebView.scrollView.contentSize.height;
        webH = self.beforeWebView.scrollView.bounds.size.height;
    }
    
    if (offsetY <= 0) {
        self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self scrollWebOffset:CGPointZero];
        self.tableView.contentOffset = CGPointZero;
    }else if (offsetY <= webContentH - webH) {
        self.contentView.frame = CGRectMake(0, offsetY, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self scrollWebOffset:CGPointMake(0, offsetY)];
        self.tableView.contentOffset = CGPointZero;
    }else if (offsetY <= webContentH) {
        self.contentView.frame = CGRectMake(0, webContentH - webH, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self scrollWebOffset:CGPointMake(0, webContentH - webH)];
        self.tableView.contentOffset = CGPointZero;
    }else if (offsetY <= webContentH + tableContentH - tableH) {
//        self.contentView.pyh_y = (offsetY - webContentH) + (webContentH - webH);//方便理解
        self.contentView.frame = CGRectMake(0, offsetY - webH, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self scrollWebOffset:CGPointMake(0, webContentH - webH)];
        self.tableView.contentOffset = CGPointMake(0, offsetY - webContentH);
    }else if (offsetY <= webContentH + tableContentH) {
//        self.contentView.pyh_y = (webContentH - webH) + (tableContentH - tableH);//方便理解
        self.contentView.frame = CGRectMake(0, self.baseScrollView.contentSize.height - CGRectGetHeight(self.contentView.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self scrollWebOffset:CGPointMake(0, webContentH - webH)];
        self.tableView.contentOffset = CGPointMake(0, tableContentH - tableH);
    }else {
        //do nothing
    }
}
- (void)scrollWebOffset:(CGPoint)point {
    if (@available(iOS 7.0, *)) {
        self.afterWebView.scrollView.contentOffset = point;
    }else {
        self.beforeWebView.scrollView.contentOffset = point;
    }
}


#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 17;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"webListID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webListID"];
    }
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.text = @"每一行";
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - lazy loading
- (UIScrollView *)baseScrollView {
    if (!_baseScrollView) {
        CGFloat y = self.navigationController ? 0 : [[UIApplication sharedApplication] statusBarFrame].size.height;
        _baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, y, kWebListW, kWebListH)];
        _baseScrollView.delegate = self;
    }
    return _baseScrollView;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWebListW, 2*kWebListH)];
    }
    return _contentView;
}
- (UIWebView *)beforeWebView {
    if (!_beforeWebView) {
        _beforeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kWebListW, kWebListH)];
        _beforeWebView.scrollView.scrollEnabled = NO;
    }
    return _beforeWebView;
}
- (WKWebView *)afterWebView {
    if (!_afterWebView) {
        _afterWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kWebListW, kWebListH)];
        _afterWebView.scrollView.scrollEnabled = NO;
        _afterWebView.navigationDelegate = self;
    }
    return _afterWebView;
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWebListW, kWebListH)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (void)dealloc {
    [self removeObserver];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
