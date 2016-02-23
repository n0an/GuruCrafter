//
//  ANVideoPlayerViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ANVideoPlayerViewController ()

@end

@implementation ANVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"ANVideoPlayerViewController videoURL = %@", self.videoURL);

    
    self.player = [[AVPlayer alloc] initWithURL:self.videoURL];
    
    [self.player play];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
