//
//  ALinWebViewController.m
//  MiaowShow
//
//  Created by ALin on 16/6/16.
//  Copyright © 2016年 ALin. All rights reserved.
//

#import "ALinWebViewController.h"

@interface ALinWebViewController ()
/** webView */
@property (nonatomic, weak) UIWebView *webView;
@end

@implementation ALinWebViewController

- (UIWebView *)webView
{
    if (!_webView) {
        UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:web];
        _webView = web;
    }
    return _webView;
}

- (instancetype)initWithUrlStr:(NSString *)url
{
    if (self = [self init]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


@end
