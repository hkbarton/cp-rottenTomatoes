//
//  MovieDetailViewController.h
//  rottenTomatoes
//
//  Created by Ke Huang on 2/7/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailViewController : UIViewController

-(MovieDetailViewController *)initWithMovie: (NSDictionary *)movie andPlaceHolderImage: (UIImage *)image;
-(void)setMovie: (NSDictionary *)movie withPlaceHolderImage: (UIImage *)image;

@end
