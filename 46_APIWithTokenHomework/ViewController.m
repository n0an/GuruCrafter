//
//  ViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ViewController.h"
#import "ANServerManager.h"
#import "ANUser.h"
#import "ANGroup.h"
#import "UIImageView+AFNetworking.h"

#import "ANPost.h"
#import "ANPostCell.h"
#import "ANImageViewGallery.h"

#import "ANPhoto.h"

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface ViewController () <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL firstTimeAppear;

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL loadingData;


@property (strong,nonatomic) NSMutableArray *postImageViewsSizesArray;


@end

static NSInteger postsInRequest = 20;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    self.postImageViewsSizesArray = [NSMutableArray array];
    self.firstTimeAppear = YES;
    
    self.loadingData = NO;

    [self getPostsFromServer];

    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    UIBarButtonItem* addPostBarButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(postOnWall:)];
    
    self.navigationItem.rightBarButtonItem = addPostBarButton;

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        
        self.firstTimeAppear = NO;
        
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
        }];
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods

- (CGFloat)heightLabelOfTextForString:(NSString *)aString fontSize:(CGFloat)fontSize widthLabel:(CGFloat)width {
    
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [aString boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attributes
                                        context:nil];
    
    return rect.size.height;
}





#pragma mark - TextImageConfigure

- (CGSize)setFramesToImageViews:(NSArray *)imageViews imageFrames:(NSArray *)imageFrames toFitSize:(CGSize)frameSize {
    
    int N = (int)imageFrames.count;
    CGRect newFrames[N];
    
    float ideal_height = MAX(frameSize.height, frameSize.width) / N;
    float seq[N];
    float total_width = 0;
    for (int i = 0; i < [imageFrames count]; i++) {
        
        if ([[imageFrames objectAtIndex:i] isKindOfClass:[ANPhoto class]]) {
            ANPhoto *image = [imageFrames objectAtIndex:i];
            CGSize size = CGSizeMake(image.width, image.height);
            CGSize newSize = CGSizeResizeToHeight(size, ideal_height);
            newFrames[i] = (CGRect) {{0, 0}, newSize};
            seq[i] = newSize.width;
            total_width += seq[i];
            
        } /* else if ([[imageFrames objectAtIndex:i] isKindOfClass:[TTVideo class]]) {
            
            CGSize size = CGSizeMake(320, 240);
            CGSize newSize = CGSizeResizeToHeight(size, ideal_height);
            newFrames[i] = (CGRect) {{0, 0}, newSize};
            seq[i] = newSize.width;
            total_width += seq[i];
        } */
        
        
    }
    
    int K = (int)roundf(total_width / frameSize.width);
    
    float M[N][K];
    float D[N][K];
    
    for (int i = 0 ; i < N; i++)
        for (int j = 0; j < K; j++)
            D[i][j] = 0;
    
    for (int i = 0; i < K; i++)
        M[0][i] = seq[0];
    
    for (int i = 0; i < N; i++)
        M[i][0] = seq[i] + (i ? M[i-1][0] : 0);
    
    float cost;
    for (int i = 1; i < N; i++) {
        for (int j = 1; j < K; j++) {
            M[i][j] = INT_MAX;
            
            for (int k = 0; k < i; k++) {
                cost = MAX(M[k][j-1], M[i][0]-M[k][0]);
                if (M[i][j] > cost) {
                    M[i][j] = cost;
                    D[i][j] = k;
                }
            }
        }
    }
    
    int k1 = K-1;
    int n1 = N-1;
    int ranges[N][2];
    while (k1 >= 0) {
        ranges[k1][0] = D[n1][k1]+1;
        ranges[k1][1] = n1;
        
        n1 = D[n1][k1];
        k1--;
    }
    ranges[0][0] = 0;
    
    float cellDistance = 5;
    float heightOffset = cellDistance, widthOffset;
    float frameWidth;
    for (int i = 0; i < K; i++) {
        float rowWidth = 0;
        frameWidth = frameSize.width - ((ranges[i][1] - ranges[i][0]) + 2) * cellDistance;
        
        for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
            rowWidth += newFrames[j].size.width;
        }
        
        float ratio = frameWidth / rowWidth;
        widthOffset = 0;
        
        for (int j = ranges[i][0]; j <= ranges[i][1]; j++) {
            newFrames[j].size.width *= ratio;
            newFrames[j].size.height *= ratio;
            newFrames[j].origin.x = widthOffset + (j - (ranges[i][0]) + 1) * cellDistance;
            newFrames[j].origin.y = heightOffset;
            
            widthOffset += newFrames[j].size.width;
        }
        heightOffset += newFrames[ranges[i][0]].size.height + cellDistance;
    }
    
    return CGSizeMake(frameSize.width, heightOffset);
}




#pragma mark - API


- (void) getPostsFromServer {
    
    if (!self.loadingData) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager]
             getGroupWall:@"58860049"
               withOffset:[self.postsArray count]
                    count:postsInRequest
                onSuccess:^(NSArray *posts) {
                    [self.postsArray addObjectsFromArray:posts];
                    
                    NSMutableArray* newPaths = [NSMutableArray array];
                    
                    for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                        [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    // *** FILLING postImagesSizesArray
                    
                    for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                        
                        CGSize newSize = [self setFramesToImageViews:nil imageFrames:[[self.postsArray objectAtIndex:i] attachmentsArray] toFitSize:CGSizeMake(302, 400)];
                        
                        [self.postImageViewsSizesArray addObject:[NSNumber numberWithFloat:roundf(newSize.height)]];
                        
                        
                    }
                    
                    
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                    
                    self.loadingData = NO;
                    
                    
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                    
                }];
        
    }
    
    
    
    
}


- (void) refreshWall {
    
    [[ANServerManager sharedManager]
     getGroupWall:@"58860049"
     withOffset:0
     count:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
         
     }];
    
    
}


- (void) postOnWall:(id) sender {
    
    [[ANServerManager sharedManager]
     postText:@"Test from 47 Lesson :-)"
     onGroupWall:@"58860049"
     onSuccess:^(id result) {
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.postsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *postIdentifier = @"postCell";

    ANPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
    
    if (!postCell) {
        postCell = [[ANPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
    }
    
    ANPost* post = [self.postsArray objectAtIndex:indexPath.row];
    
    if (post.fromGroup != nil) {
        postCell.fullNameLabel.text = post.fromGroup.groupName;
        [postCell.postAuthorImageView setImageWithURL:post.fromGroup.imageURL];


    } else if (post.author != nil) {
        postCell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", post.author.firstName, post.author.lastName];
        [postCell.postAuthorImageView setImageWithURL:post.author.imageURL];

    }
    
    
    
    postCell.postTextLabel.text = post.text;
    
    CGRect rect = postCell.postTextLabel.frame;
    rect.size.height = [self heightLabelOfTextForString:post.text fontSize:15.f widthLabel:CGRectGetWidth(rect)];
    postCell.postTextLabel.frame = rect;
    
    postCell.dateLabel.text = post.date;
    
    postCell.commentsCountLabel.text = post.comments;
    postCell.likesCountLabel.text = post.likes;
    
    
    
    
    
    // *** ADDING IMAGES
    
    if ([post.attachmentsArray count] > 0) {
        
        CGPoint point = CGPointZero;
        
        if (![post.text isEqualToString:@""]) {
            point = CGPointMake(CGRectGetMinX(postCell.postTextLabel.frame),CGRectGetMaxY(postCell.postTextLabel.frame));
        } else {
            point = CGPointMake(CGRectGetMinX(postCell.postAuthorImageView.frame),CGRectGetMaxY(postCell.postAuthorImageView.frame));
        }
        
        
        ANImageViewGallery* gallery = [[ANImageViewGallery alloc] initWithImageArray:post.attachmentsArray startPoint:point];
        
        gallery.tag = 11;
        
        [postCell addSubview:gallery];
        
        
        
        
    }
    
    
    
    return postCell;
    
}



#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return UITableViewAutomaticDimension;
//    
//}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    return UITableViewAutomaticDimension; // Auto Layout elements in the cell
    
    
    ANPost *post = [self.postsArray objectAtIndex:indexPath.row];
    
    float height = 0;
    
    if (![post.text isEqualToString:@""]) {
        height = height + (int)[self heightLabelOfTextForString:post.text fontSize:15.f widthLabel:300];
    }
    
    if ([post.attachmentsArray count] > 0) {
        
        height = height + [[self.postImageViewsSizesArray objectAtIndex:indexPath.row]floatValue];
    }
    
    return 46 + 10 + height + 20;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}





#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
//            self.loadingData = YES;
            [self getPostsFromServer];
        }
    }
}







@end
