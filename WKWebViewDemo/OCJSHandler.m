//
//  JSOCHandler.m
//  WKWebViewDemo
//
//  Created by caifeng on 2017/2/8.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import "OCJSHandler.h"

@interface OCJSHandler ()

@property (nonatomic, weak) UIViewController *vc;

@end

@implementation OCJSHandler

//- (instancetype)initWithDelegate:(id<JSOCHandlerDelegate>)delegate vc:(UIViewController *)vc{
//   
//    if (self = [super init]) {
//        
//        self.delegate = delegate;
//        self.vc = vc;
//    }
//    return self;
//}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"userContentController--%@-%@-%@", message.body, message.name, [NSThread currentThread]);
    NSDictionary *dic = message.body;
    if ([message.name isEqualToString:@"jsInvokObject"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([dic[@"code"] isEqualToString:@"0001"]) {
                
                NSString *js = [NSString stringWithFormat:@"globalCallback(\'%@\')", @"该设备的deviceId: *****"];
                NSLog(@"%@", self.webView);
                [self.webView evaluateJavaScript:js completionHandler:nil];
            }
        });
    }
}

@end
