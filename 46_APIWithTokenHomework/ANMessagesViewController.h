//
//  ANMessagesViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ViewController.h"

@class ANUser;
@class ANGroup;

@interface ANMessagesViewController : UITableViewController

//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString* partnerUserID;

@property (strong, nonatomic) ANUser* partnerUser;
@property (strong, nonatomic) ANGroup* partnerGroup;



- (IBAction)actionComposePressed:(UIBarButtonItem*)sender;




@end
