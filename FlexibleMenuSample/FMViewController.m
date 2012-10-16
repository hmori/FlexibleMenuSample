//
//  FMViewController.m
//  FlexibleMenuSample
//
//  Created by Hidetoshi Mori on 12/10/15.
//  Copyright (c) 2012年 Hidetoshi Mori. All rights reserved.
//

#import "FMViewController.h"

static NSString *kTitle = @"Title";

@interface FMViewController ()
@end

@implementation FMViewController
@synthesize node = _node;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.node) {
        self.title = [self.node objectForKey:kTitle];
    }
}

@end
