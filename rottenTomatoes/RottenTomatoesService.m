//
//  RottenTomatoesService.m
//  rottenTomatoes
//
//  Created by Ke Huang on 2/3/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import "RottenTomatoesService.h"

NSString *const URL_MOVIES = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=sjnf72r7y5csckay8gt3y6xn";
NSString *const URL_DVDS = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals?apikey=sjnf72r7y5csckay8gt3y6xn";
static RottenTomatoesService *_defaultService = nil;

@implementation RottenTomatoesService

- (void) getMovieData:(NSString*) url withCallback:(void(^)(NSArray *data, NSError *err)) callback {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString: url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
        NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        callback(returnData[@"movies"], connectionError);
    }];
}

- (void) getMovies:(void(^)(NSArray *data, NSError *err)) callback {
    [self getMovieData:URL_MOVIES withCallback:callback];
}

- (void) getDVDs:(void(^)(NSArray *data, NSError *err)) callback {
    [self getMovieData:URL_DVDS withCallback:callback];
}

+ (id)defaultService {
    if (_defaultService == nil) {
        _defaultService = [[RottenTomatoesService alloc] init];
    }
    return _defaultService;
}

@end
