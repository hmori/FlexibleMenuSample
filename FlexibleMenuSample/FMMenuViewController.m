//
//  FMMenuViewController.m
//  FlexibleMenuSample
//
//  Created by Hidetoshi Mori on 12/10/15.
//  Copyright (c) 2012年 Hidetoshi Mori. All rights reserved.
//

#import "FMMenuViewController.h"
#import "FMViewController.h"

static NSString *kNode = @"Node";
static NSString *kTitle = @"Title";
static NSString *kTable = @"Table";
static NSString *kSectionTitle = @"SectionTitle";
static NSString *kSectionFooter = @"SectionFooter";
static NSString *kRows = @"Rows";
static NSString *kHeight = @"Height";
static NSString *kCellIdentifier = @"CellIdentifier";
static NSString *kText = @"Text";
static NSString *kDetailText = @"DetailText";
static NSString *kSegueIdentifier = @"SegueIdentifier";

static NSString *kStoryboardIdentifier = @"Main";
static NSString *kMenuControllerIdentifier = @"menu";
static NSString *kMenuSegue = @"menuSegue";

static NSString *kPlistName = @"Menu.plist";
static NSString *kRequestUrl = @"https://dl.dropbox.com/u/8511076/sample/Menu.json";


@interface FMMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateButton;
- (IBAction)updateAction:(UIBarButtonItem *)sender;
- (NSArray *)tables;
- (NSDictionary *)sectionItem:(NSInteger)section;
- (NSArray *)rows:(NSInteger)section;
- (NSDictionary *)rowItem:(NSIndexPath *)indexPath;
- (NSString *)documentFilepath;
- (void)loadData;
- (void)requestData;
- (void)refreshData:(id)sender;
@end


@implementation FMMenuViewController
@synthesize node = _node;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //remove update button when other top level
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (_node) {
        self.title = [_node objectForKey:kTitle];
    } else {
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self tables] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self sectionItem:section] objectForKey:kSectionTitle];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [[self sectionItem:section] objectForKey:kSectionFooter];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self rows:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [[[self rowItem:indexPath] objectForKey:kHeight] floatValue];
    if (height <= 0) {
        return 44.0f; //default height
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowItem = [self rowItem:indexPath];
    NSString *cellIdentifier = [rowItem objectForKey:kCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = [rowItem objectForKey:kText];
    cell.detailTextLabel.text = [rowItem objectForKey:kDetailText];
    
    NSString *segueIdentifier = [rowItem objectForKey:kSegueIdentifier];
    if (segueIdentifier.length > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowItem = [self rowItem:indexPath];
    NSString *segueIdentifier = [rowItem objectForKey:kSegueIdentifier];
    
    if (segueIdentifier.length > 0) {
        if ([segueIdentifier isEqualToString:kMenuSegue]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardIdentifier bundle:nil];
            FMMenuViewController *ctl = [storyboard instantiateViewControllerWithIdentifier:kMenuControllerIdentifier];
            ctl.node = [rowItem objectForKey:kNode];
            [self.navigationController pushViewController:ctl animated:YES];
        } else {
            @try {
                [self performSegueWithIdentifier:segueIdentifier sender:rowItem];
            }
            @catch (NSException *exception) {
                NSLog(@"NSException : performSegueWithIdentifier : %@", exception);
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIViewController segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FMViewController *viewController = segue.destinationViewController;
    [viewController setNode:[sender objectForKey:kNode]];
}

#pragma mark - IBAction

- (IBAction)updateAction:(UIBarButtonItem *)sender {
    [self requestData];
}

#pragma mark - Private methods

- (NSArray *)tables {
    return [_node objectForKey:kTable];
}

- (NSDictionary *)sectionItem:(NSInteger)section {
    return [[self tables] objectAtIndex:section];
}

- (NSArray *)rows:(NSInteger)section {
    return [[[self tables] objectAtIndex:section] objectForKey:kRows];
}

- (NSDictionary *)rowItem:(NSIndexPath *)indexPath {
    return [[self rows:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSString *)documentFilepath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [docPath stringByAppendingPathComponent:kPlistName];
}

- (void)loadData {
    NSString *filepath = [self documentFilepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        //load local file
        self.node = [[NSDictionary dictionaryWithContentsOfFile:filepath] objectForKey:kNode];
        self.title = [_node objectForKey:kTitle];
    } else {
        //request load data
        [self requestData];
    }
}

- (void)requestData {
    
    NSURL *url = [NSURL URLWithString:kRequestUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0f];
    
    //indicator start
    [self.indicator startAnimating];
    
    __block FMMenuViewController *weakSelf = self;
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         //indicator stop
         [weakSelf.indicator performSelectorOnMainThread:@selector(stopAnimating)
                                              withObject:nil
                                           waitUntilDone:YES];
         if (!error) {
             //parse JSON format
             NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:nil];
             //write local file
             [root writeToFile:[weakSelf documentFilepath] atomically:YES];
             
             weakSelf.node = [root objectForKey:kNode];
             [weakSelf performSelectorOnMainThread:@selector(refreshData:)
                                        withObject:nil
                                     waitUntilDone:YES];
         }
     }];
}

- (void)refreshData:(id)sender {
    self.title = [_node objectForKey:kTitle];
    [self.tableView reloadData];
}

@end
