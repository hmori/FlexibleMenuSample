//
//  FMWebViewController.m
//  FlexibleMenuSample
//
//  Created by Hidetoshi Mori on 12/10/15.
//  Copyright (c) 2012年 Hidetoshi Mori. All rights reserved.
//

#import "FMWebViewController.h"

static NSString *kUrl = @"Url";

@interface FMWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.node) {
        NSString *url = [self.node objectForKey:kUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
