//
//  ANVideoPlayerViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideoPlayerViewController.h"
#import "ANVideo.h"

@interface ANVideoPlayerViewController ()

@end

@implementation ANVideoPlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"ANVideoPlayerViewController videoPlayerURLString = %@", self.selectedVideo.videoPlayerURLString);
    
    NSString* newString = [self.selectedVideo.videoPlayerURLString stringByAppendingString:@"&showinfo=0"];
    
    NSURL* urlVideo = [NSURL URLWithString:newString];

//    NSURL* urlVideo = [NSURL URLWithString:self.selectedVideo.videoPlayerURLString];
    
    NSURLRequest* requestToYoutube = [NSURLRequest requestWithURL:urlVideo];
    
    [self.playerWebView loadRequest:requestToYoutube];
    
    self.titleLabel.text = self.selectedVideo.title;
    self.descriptionLabel.text = self.selectedVideo.videoDescription;
    self.likesCountLabel.text = self.selectedVideo.likesCount;
    self.viewsCountLabel.text = self.selectedVideo.views;
    self.dateLabel.text = [NSString stringWithFormat:@"Added on %@", self.selectedVideo.date];
    
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancelPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void) actionCancelPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionCancelPressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
