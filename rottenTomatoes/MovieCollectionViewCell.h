//
//  MovieCollectionViewCell.h
//  rottenTomatoes
//
//  Created by Ke Huang on 2/5/15.
//  Copyright (c) 2015 Ke Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@end
