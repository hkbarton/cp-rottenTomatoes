//
//  RottenTomatoesService.h
//  rottenTomatoes
//
//  Created by Ke Huang on 2/3/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RottenTomatoesService : NSObject

- (void) getMovies:(void(^)(NSArray *data, NSError *err)) callback;
- (void) getDVDs:(void(^)(NSArray *data, NSError *err)) callback;

+ (id)defaultService;

@end
