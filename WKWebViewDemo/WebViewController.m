//
//  WebViewController.m
//  WKWebViewDemo
//
//  Created by caifeng on 2017/2/8.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "OCJSHandler.h"

#define mScreenWidth [UIScreen mainScreen].bounds.size.width
#define mScreenHeight [UIScreen mainScreen].bounds.size.height

static CGFloat addViewHeight = 500;   // 添加自定义 View 的高度
static BOOL showAddView = YES;        // 是否添加自定义 View
static BOOL useEdgeInset = NO;        // 用哪种方法添加自定义View， NO 使用 contentInset，YES 使用 div

@interface WebViewController () <
                                 WKUIDelegate,
                                 WKNavigationDelegate,
                                 UIScrollViewDelegate
                                >

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) OCJSHandler *ocJSHandler;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) CGFloat delayTime;

@property (nonatomic, strong) UIView *addView;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation WebViewController

- (NSURL *)testUrl {
    
    NSURL *url = [NSURL URLWithString:@"https://m.baidu.com"];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    
    return url;
}

- (OCJSHandler *)ocJSHandler {

    if (_ocJSHandler == nil) {
        
        _ocJSHandler = [[OCJSHandler alloc] init];
    }
    return _ocJSHandler;
}

- (UIView *)addView {
    if (!_addView) {
        _addView = [[UIView alloc] init];
        _addView.backgroundColor = [UIColor redColor];
    }
    return _addView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 设置是否允许嵌入播放网页视频 yes 允许  no 弹出满屏控制器播放
    config.allowsInlineMediaPlayback = YES;

    // 网页本地化存储设置 nonPersistentDataStore 不持久化存储
//    config.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
    
    // 设置交互对象 js调用oc方法
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addScriptMessageHandler:self.ocJSHandler name:@"jsInvokObject"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.delegate = self;

    [self.view addSubview:self.webView];
    
    // 关联webView
    self.ocJSHandler.webView = self.webView;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[self testUrl]]];

    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, mScreenWidth, 2)];
    [self.view addSubview:self.progressView];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor clearColor];
    
    [self addObservers];
}

#pragma mark - Helper Methods
- (void)addObservers {
    
    NSKeyValueObservingOptions observingOptions = NSKeyValueObservingOptionNew;
    // KVO 监听属性
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:observingOptions context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:observingOptions context:nil];
    
    // 监听 self.webView.scrollView 的 contentSize 属性改变，从而对底部添加的自定义 View 进行位置调整
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:observingOptions context:nil];
}

- (void)removeObservers {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"timefor"];
}

#pragma mark - WKUIDelegate

// 需要重新打开一个webview时调用 navigationAction 的targetFrame != mainFrame时就会离开当前webView
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"createWebViewWithConfiguration--%@", navigationAction);
    return nil;
}

// 关闭一个webView时调用
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"webViewDidClose");
}

// 弹出js交互alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"runJavaScriptAlertPanelWithMessage--%@", message);
    completionHandler();
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 弹出js交互确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 弹出js交互输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"TextInputPanel" message:prompt preferredStyle:UIAlertControllerStyleAlert];
   
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([alert.textFields lastObject].text);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

// 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation   ====    %@", navigation);
}

// 页面加载完调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didFinishNavigation   ====    %@", navigation);
    
    if (!showAddView) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.webView.scrollView addSubview:self.addView];
        
        if (useEdgeInset) {
            // url 使用 test.html 对比更明显
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0, addViewHeight, 0);
        } else {
            NSString *js = [NSString stringWithFormat:@"\
                            var appendDiv = document.getElementById(\"AppAppendDIV\");\
                            if (appendDiv) {\
                            appendDiv.style.height = %@+\"px\";\
                            } else {\
                            var appendDiv = document.createElement(\"div\");\
                            appendDiv.setAttribute(\"id\",\"AppAppendDIV\");\
                            appendDiv.style.width=%@+\"px\";\
                            appendDiv.style.height=%@+\"px\";\
                            document.body.appendChild(appendDiv);\
                            }\
                            ", @(addViewHeight), @(mScreenWidth), @(addViewHeight)];
            [self.webView evaluateJavaScript:js completionHandler:^(id value, NSError *error) {
                // 执行完上面的那段 JS, webView.scrollView.contentSize.height 的高度已经是加上 div 的高度
                self.addView.frame = CGRectMake(0, self.webView.scrollView.contentSize.height - addViewHeight, mScreenWidth, addViewHeight);
            }];
        }
    });
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation   ====    %@\nerror   ====   %@", navigation, error);
}

// 内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didCommitNavigation   ====    %@", navigation);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationAction   ====    %@", navigationAction);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse   ====    %@", navigationResponse);
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.webView evaluateJavaScript:@"parseFloat(document.getElementById(\"AppAppendDIV\").style.width);" completionHandler:^(id value, NSError * _Nullable error) {
        NSLog(@"addView width======= %@", value);
    }];
    
    [self.webView evaluateJavaScript:@"parseFloat(document.getElementById(\"AppAppendDIV\").style.height);" completionHandler:^(id value, NSError * _Nullable error) {
        NSLog(@"addView height======= %@", value);
    }];
}

#pragma mark - KVO 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
   
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress < 1.0) {
            self.delayTime = 1 - self.webView.estimatedProgress;
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.progress = 0;
        });
        
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        if (self.contentHeight != self.webView.scrollView.contentSize.height) {
            self.contentHeight = self.webView.scrollView.contentSize.height;
            self.addView.frame = CGRectMake(0, self.contentHeight - addViewHeight, mScreenWidth, addViewHeight);
            NSLog(@"----------%@", NSStringFromCGSize(self.webView.scrollView.contentSize));
        }
    }

}


- (void)dealloc {
    NSLog(@"Web VC Delloc");
    [self removeObservers];
}

@end
