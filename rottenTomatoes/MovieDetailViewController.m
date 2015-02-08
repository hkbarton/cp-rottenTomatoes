//
//  MovieDetailViewController.m
//  rottenTomatoes
//
//  Created by Ke Huang on 2/7/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelScore;
@property (weak, nonatomic) IBOutlet UILabel *labelRating;
@property (weak, nonatomic) IBOutlet UITextView *textDetail;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@property (strong, nonatomic) NSDictionary *movie;
@property (strong, nonatomic) UIImage *placeholderImage;

@end

@implementation MovieDetailViewController

CGFloat upperLimitOfScrollView, lowerLimitOfScrollView, upperLimitOfAutoScroll, lowerLimtOfAutoScroll, centerYOfScrollView;
CGFloat initYPosWhenStartPan, restDistance;

-(MovieDetailViewController *)initWithMovie: (NSDictionary *)movie andPlaceHolderImage: (UIImage *)image {
    if (self = [super init]) {
        self.movie = movie;
        self.placeholderImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movie Detail";
    
    self.textDetail.editable = YES;
    self.textDetail.font = [UIFont systemFontOfSize:17.0f];
    self.textDetail.editable = NO;
    self.textDetail.textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    self.panGesture.delegate = self;
    
    upperLimitOfScrollView = 63.0f;
    lowerLimtOfAutoScroll = 150.0f;
    lowerLimitOfScrollView = [[UIScreen mainScreen] bounds].size.height - 140.0f;
    upperLimitOfAutoScroll = lowerLimitOfScrollView - 60.0f;
    centerYOfScrollView = upperLimitOfAutoScroll + (lowerLimtOfAutoScroll - upperLimitOfAutoScroll) / 2;
    
    [self renderView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    initYPosWhenStartPan = self.scrollView.frame.origin.y;
    restDistance = 0.0f;
    return YES;
}

- (IBAction)handlePanGesture:(id)sender {
    CGPoint velocity = [self.panGesture velocityInView:self.view];
    CGPoint position = [self.panGesture translationInView:self.view];
    CGRect scrollViewFrame = self.scrollView.frame;
    // slow move
    if (self.panGesture.state != UIGestureRecognizerStateEnded) {
        scrollViewFrame.origin.y = initYPosWhenStartPan + position.y;
        if (scrollViewFrame.origin.y < upperLimitOfScrollView) {
            scrollViewFrame.origin.y = upperLimitOfScrollView;
        } else if (scrollViewFrame.origin.y > lowerLimitOfScrollView) {
            scrollViewFrame.origin.y = lowerLimitOfScrollView;
        }
        restDistance = position.y > 0 ? lowerLimitOfScrollView - scrollViewFrame.origin.y : scrollViewFrame.origin.y - upperLimitOfScrollView;
        self.scrollView.frame = scrollViewFrame;
    // fast move or stop pan
    } else {
        // animate to top if needed
        if ((scrollViewFrame.origin.y <= upperLimitOfAutoScroll && position.y < 0) || velocity.y < -500) {
            scrollViewFrame.origin.y = upperLimitOfScrollView;
        // animate to bottom if needed
        } else if ((scrollViewFrame.origin.y > lowerLimtOfAutoScroll && position.y > 0) || velocity.y > 500) {
            scrollViewFrame.origin.y = lowerLimitOfScrollView;
        // maintain current position (top of bottom)
        } else {
            scrollViewFrame.origin.y = scrollViewFrame.origin.y < centerYOfScrollView ? upperLimitOfScrollView : lowerLimitOfScrollView;
        }
        CGFloat animationDuration = (restDistance / (lowerLimitOfScrollView - upperLimitOfScrollView)) * 0.3f;
        [UIView animateWithDuration:animationDuration animations:^{
            self.scrollView.frame = scrollViewFrame;
        }];
    }
}

-(void)renderView {
    // set data
    NSString *oriImageUrl = [self.movie valueForKeyPath:@"posters.thumbnail"];
    oriImageUrl = [oriImageUrl stringByReplacingOccurrencesOfString:@"_tmb.jpg" withString:@"_ori.jpg"];
    [self.posterView setImageWithURL:[NSURL URLWithString:oriImageUrl] placeholderImage:self.placeholderImage];
    self.labelTitle.text = [self.movie valueForKeyPath:@"title"];
    self.labelScore.text = [NSString stringWithFormat:@"Critics: %@  Audience: %@", [self.movie valueForKeyPath:@"ratings.critics_score"], [self.movie valueForKeyPath:@"ratings.audience_score"]];
    self.labelRating.text = [self.movie valueForKeyPath:@"mpaa_rating"];
    self.textDetail.text = [self.movie valueForKeyPath:@"synopsis"];
    // set init frame of scroll view
    [self.scrollView setFrame:CGRectMake(0, lowerLimitOfScrollView, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
}

-(void)setMovie: (NSDictionary *)movie  withPlaceHolderImage: (UIImage *)image {
    self.movie = movie;
    self.placeholderImage = image;
    [self renderView];
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
