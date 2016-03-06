//
//  ANSideBarViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 28/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANSideBarViewController.h"
#import "SWRevealViewController.h"


@interface ANSideBarViewController ()

@property (strong, nonatomic) NSArray* menuItems;

@end


@implementation ANSideBarViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.menuItems = [NSArray arrayWithObjects:
                      @"menuHeaderCell",
                      @"wallCell",
                      @"photoAlbumsCell",
                      @"videoAlbumsCell",
                      nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.menuItems count];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* cellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return cell;
    
}







@end
