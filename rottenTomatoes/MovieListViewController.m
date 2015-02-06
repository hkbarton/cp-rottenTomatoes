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
#import "MovieCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

NSString *const TABLE_VIEW_CELL_ID = @"MovieTableViewCell";
NSString *const COLLECTION_VIEW_CELL_ID = @"MovieCollectionViewCell";
NSString *const MOVIE_POSTER = @"posters.profile";
NSString *const MOVIE_TITLE = @"title";
NSString *const MOVIE_RATING = @"mpaa_rating";
NSString *const MOVIE_SYNOPSIS = @"synopsis";

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewMovies;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UIView *viewErrorOverlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowList;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowGallery;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;

@property (nonatomic, strong) NSArray *movieList;

@end

@implementation MovieListViewController

@synthesize movieList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Movies";
    [self.buttonShowList setSelected:YES];
    [self.buttonShowGallery setSelected:NO];
    
    self.tableViewMovies.dataSource = self;
    self.tableViewMovies.delegate = self;
    [self.tableViewMovies registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:TABLE_VIEW_CELL_ID];
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableViewMovies insertSubview:self.tableRefreshControl atIndex:0];
    
    self.collectionViewMovies.dataSource = self;
    self.collectionViewMovies.delegate = self;
    [self.collectionViewMovies registerNib:[UINib nibWithNibName:@"MovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:COLLECTION_VIEW_CELL_ID];
    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    [self.collectionRefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.collectionViewMovies insertSubview:self.collectionRefreshControl atIndex:0];
    
    [self refreshMoviesView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonShowListClick:(id)sender {
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [self.buttonShowGallery setSelected:NO];
        // TODO update image
        [self refreshMoviesView];
    }
}

- (IBAction)onButtonShowGalleryClick:(id)sender {
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [self.buttonShowList setSelected:NO];
        // TODO update image
        [self refreshMoviesView];
    }
}

#pragma mark - Util

- (void)refreshData {
    self.viewErrorOverlay.hidden = YES;
    [[RottenTomatoesService defaultService] getMovies:^(NSArray *data, NSError *err) {
        if (err != nil) {
            self.viewErrorOverlay.hidden = NO;
            if ([self.buttonShowList isSelected]) {
                [self.tableRefreshControl endRefreshing];
            } else if ([self.buttonShowGallery isSelected]) {
                [self.collectionRefreshControl endRefreshing];
            }
            return;
        }
        self.movieList = data;
        if ([self.buttonShowList isSelected]) {
            [self.tableViewMovies reloadData];
            [self.tableRefreshControl endRefreshing];
        } else if ([self.buttonShowGallery isSelected]) {
            [self.collectionViewMovies reloadData];
            [self.collectionRefreshControl endRefreshing];
        }
    }];
}

-(void)refreshMoviesView {
    if ([self.buttonShowList isSelected]) {
        self.tableViewMovies.hidden = NO;
        self.collectionViewMovies.hidden = YES;
    } else if ([self.buttonShowGallery isSelected]) {
        self.tableViewMovies.hidden = YES;
        self.collectionViewMovies.hidden = NO;
    }
    [self refreshData];
}

- (void)loadImage:(__weak UIImageView *)imageView withURL:(NSString *)url {
    NSURL *posterUrl = [NSURL URLWithString:url];
    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:posterUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3.0f];
    [imageView setImageWithURLRequest:posterRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
        // Only animate image fade in when result come from network
        if (response != nil) {
            imageView.alpha = 0;
            [UIView animateWithDuration:0.7f animations:^{
                imageView.alpha = 1.0f;
            }];
        }
    } failure:nil];
}

#pragma mark - Table View

// fix separator inset bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movieList.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movieList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *view = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIEW_CELL_ID forIndexPath:indexPath];
    
    NSDictionary *movie = movieList[indexPath.row];
    [self loadImage:view.posterView withURL:[movie valueForKeyPath:MOVIE_POSTER]];
    view.labelTitle.text = [movie valueForKeyPath:MOVIE_TITLE];
    
    return view;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

@end
