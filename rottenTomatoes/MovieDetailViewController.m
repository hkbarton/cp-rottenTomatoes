//
//  MovieDetailViewController.m
//  rottenTomatoes
//
//  Created by Ke Huang on 2/7/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelScore;
@property (weak, nonatomic) IBOutlet UILabel *labelRating;
@property (weak, nonatomic) IBOutlet UITextView *textDetail;

@property (strong, nonatomic) NSDictionary *movie;
@property (strong, nonatomic) UIImage *placeholderImage;

@end

@implementation MovieDetailViewController

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
    [self renderView];
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
    // set position of scroll view
    [self.scrollView setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 140, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
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
