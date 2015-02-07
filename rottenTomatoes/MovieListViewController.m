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
#import "SVProgressHUD.h"
#import "MovieDetailViewController.h"

NSString *const TABLE_VIEW_CELL_ID = @"MovieTableViewCell";
NSString *const COLLECTION_VIEW_CELL_ID = @"MovieCollectionViewCell";
NSString *const MOVIE_POSTER = @"posters.profile";
NSString *const MOVIE_TITLE = @"title";
NSString *const MOVIE_RATING = @"mpaa_rating";
NSString *const MOVIE_SYNOPSIS = @"synopsis";

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMovies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewMovies;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UIView *viewErrorOverlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowList;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowGallery;
@property (weak, nonatomic) IBOutlet UITabBar *tabSource;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabItemMovie;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabItemDVD;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;
@property (nonatomic, strong) MovieDetailViewController *movieDetailViewController;

@property (nonatomic, strong) NSArray *movieList;
@property (nonatomic, strong) NSArray *filtedMovieList;

@end

@implementation MovieListViewController

__weak UITabBarItem *_curSelectItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Movies";
    [self.buttonShowList setSelected:YES];
    [self.buttonShowGallery setSelected:NO];

    self.tabSource.delegate = self;
    [self.tabSource setSelectedItem: self.tabItemMovie];
    _curSelectItem = self.tabItemMovie;
    
    self.searchBar.delegate = self;

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
    
    [self refreshMoviesView:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.movieDetailViewController = nil;
}

- (IBAction)onButtonShowListClick:(id)sender {
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [self.buttonShowGallery setSelected:NO];
        // TODO update image
        [self refreshMoviesView:NO];
    }
}

- (IBAction)onButtonShowGalleryClick:(id)sender {
    if (![sender isSelected]) {
        [sender setSelected:YES];
        [self.buttonShowList setSelected:NO];
        // TODO update image
        [self refreshMoviesView:NO];
    }
}

#pragma mark - Util

- (void)filterMovieBySearchText {
    NSString *searchText = self.searchBar.text;
    if (searchText.length == 0) {
        self.filtedMovieList = [NSArray arrayWithArray:self.movieList];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", MOVIE_TITLE, searchText];
        self.filtedMovieList = [self.movieList filteredArrayUsingPredicate:predicate];
    }
}

- (void)refreshData {
    self.viewErrorOverlay.hidden = YES;
    
    void (^callback)(NSArray *data, NSError *err) = ^(NSArray *data, NSError *err) {
        [SVProgressHUD dismiss];
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
        [self filterMovieBySearchText];
        if ([self.buttonShowList isSelected]) {
            [self.tableViewMovies reloadData];
            [self.tableRefreshControl endRefreshing];
        } else if ([self.buttonShowGallery isSelected]) {
            [self.collectionViewMovies reloadData];
            [self.collectionRefreshControl endRefreshing];
        }
    };
    
    if (self.tabSource.selectedItem == self.tabItemMovie) {
        [[RottenTomatoesService defaultService] getMovies: callback];
    } else if (self.tabSource.selectedItem == self.tabItemDVD) {
        [[RottenTomatoesService defaultService] getDVDs: callback];
    }
}

-(void)refreshMoviesView: (BOOL)shouldReloadData {
    if ([self.buttonShowList isSelected]) {
        self.tableViewMovies.hidden = NO;
        if (shouldReloadData) {
            [self.tableViewMovies scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        [self.tableViewMovies reloadData];
        self.collectionViewMovies.hidden = YES;
    } else if ([self.buttonShowGallery isSelected]) {
        self.tableViewMovies.hidden = YES;
        self.collectionViewMovies.hidden = NO;
        if (shouldReloadData) {
            [self.collectionViewMovies scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        }
        [self.collectionViewMovies reloadData];
    }
    if (shouldReloadData) {
        [SVProgressHUD show];
        [self refreshData];
    }
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

- (void)showMovieDetail: (NSDictionary *)movie withPlaceHolderImage: (UIImage *) image{
    if (self.movieDetailViewController == nil) {
        self.movieDetailViewController = [[MovieDetailViewController alloc] initWithMovie:movie andPlaceHolderImage:image];
    } else {
        [self.movieDetailViewController setMovie:movie withPlaceHolderImage:image];
    }
    [self.navigationController pushViewController:self.movieDetailViewController animated:YES];
}

#pragma mark - Tab Bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item != _curSelectItem) {
        [self refreshMoviesView:YES];
    }
    _curSelectItem = item;
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterMovieBySearchText];
    [self refreshMoviesView:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [self filterMovieBySearchText];
    [self refreshMoviesView:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
    return self.filtedMovieList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieTableViewCell *view = [tableView dequeueReusableCellWithIdentifier:TABLE_VIEW_CELL_ID];
    
    NSDictionary *movie = self.filtedMovieList[indexPath.row];
    [self loadImage:view.posterView withURL:[movie valueForKeyPath:MOVIE_POSTER]];
    view.labelTitle.text = [movie valueForKeyPath:MOVIE_TITLE];
    view.labelRating.text = [movie valueForKeyPath:MOVIE_RATING];
    view.labelSynopsis.text = [movie valueForKeyPath:MOVIE_SYNOPSIS];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieTableViewCell *view = (MovieTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    UIImage *image = view.posterView.image;
    [self showMovieDetail:self.filtedMovieList[indexPath.row] withPlaceHolderImage:image];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filtedMovieList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *view = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIEW_CELL_ID forIndexPath:indexPath];
    
    NSDictionary *movie = self.filtedMovieList[indexPath.row];
    [self loadImage:view.posterView withURL:[movie valueForKeyPath:MOVIE_POSTER]];
    view.labelTitle.text = [movie valueForKeyPath:MOVIE_TITLE];
    
    return view;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MovieCollectionViewCell *view = (MovieCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *image = view.posterView.image;
    [self showMovieDetail:self.filtedMovieList[indexPath.row] withPlaceHolderImage:image];
}

@end
