//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by caifeng on 2017/2/8.
//  Copyright © 2017年 facaishu. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (IBAction)pushToWebViewController:(id)sender {
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.title = @"Web VC";
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"沙盒路径--%@", NSHomeDirectory());
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
