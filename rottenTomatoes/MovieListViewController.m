//
//  MovieListViewController.m
//  rottenTomatoes
//
//  Created by Ke Huang on 2/2/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import "MovieListViewController.h"

@interface MovieListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMovies;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Movies";
    self.tableViewMovies.dataSource = self;
    self.tableViewMovies.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *view = [[UITableViewCell alloc] init];
    view.textLabel.text = @"Hello";
    return view;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
