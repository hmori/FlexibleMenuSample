//
//  FMMenuViewController.h
//  FlexibleMenuSample
//
//  Created by Hidetoshi Mori on 12/10/15.
//  Copyright (c) 2012年 Hidetoshi Mori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMMenuViewController : UITableViewController {
    NSDictionary *_node;
}
@property (strong, nonatomic) NSDictionary *node;

@end
