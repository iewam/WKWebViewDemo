//
//  JSOCHandler.h
//  WKWebViewDemo
//
//  Created by caifeng on 2017/2/8.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

//@protocol JSOCHandlerDelegate <NSObject>
//
//@optional
//
//@end

@interface OCJSHandler : NSObject <WKScriptMessageHandler>

//@property (nonatomic, weak) id<JSOCHandlerDelegate> delegate;
@property (nonatomic, weak) WKWebView *webView;

//- (instancetype)initWithDelegate:(id<JSOCHandlerDelegate>)delegate vc:(UIViewController *)vc;

@end
