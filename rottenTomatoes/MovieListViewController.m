//
//  MovieListViewController.m
//  rottenTomatoes
//
//  Created by Ke Huang on 2/2/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import "MovieListViewController.h"
#import "RottenTomatoesService.h"
#import "MovieTableViewCell.h"
#import "UIImageView+AFNetworking.h"

NSString *const TABLE_VIEW_CELL_ID = @"MovieItem";
NSString *const MOVIE_POSTER = @"posters.profile";
NSString *const MOVIE_TITLE = @"title";
NSString *const MOVIE_RATING = @"mpaa_rating";
NSString *const MOVIE_SYNOPSIS = @"synopsis";

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMovies;
@property (nonatomic, strong) NSArray *movieList;

@end

@implementation MovieListViewController

@synthesize movieList;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movies";
    self.tableViewMovies.dataSource = self;
    self.tableViewMovies.delegate = self;
    [self.tableViewMovies registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:TABLE_VIEW_CELL_ID];
    [self refreshData];
}

- (void)refreshData {
    [[RottenTomatoesService defaultService] getMovies:^(NSArray *data, NSError *err) {
        self.movieList = data;
        [self.tableViewMovies reloadData];
    }];
}

#pragma mark - Util

- (void)loadImage:(__weak UIImageView *)imageView withURL:(NSString *)url {
    NSURL *posterUrl = [NSURL URLWithString:url];
    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:posterUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3.0f];
    [imageView setImageWithURLRequest:posterRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
    } failure:nil];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movieList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieTableViewCell *view = [tableView dequeueReusableCellWithIdentifier:TABLE_VIEW_CELL_ID];
    
    NSDictionary *movie = movieList[indexPath.row];
    [self loadImage:view.posterView withURL:[movie valueForKeyPath:MOVIE_POSTER]];
    view.labelTitle.text = [movie valueForKeyPath:MOVIE_TITLE];
    view.labelRating.text = [movie valueForKeyPath:MOVIE_RATING];
    view.labelSynopsis.text = [movie valueForKeyPath:MOVIE_SYNOPSIS];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
