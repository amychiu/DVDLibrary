//
//  SearchViewController.h
//  DVDLibrary
//
//  Created by Amy Chiu on 3/2/14.
//  Copyright (c) 2014 Ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface SearchViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *upcMovieResults;
@property (strong, nonatomic) NSMutableDictionary *titleMovieResults;
@property (strong, nonatomic) NSMutableDictionary *movieInfo;
@property (strong, nonatomic) NSMutableDictionary *movieImdbInfo;

@property (strong, nonatomic) Movie *foundMovie;

@property (strong, nonatomic) NSString *roviApiKey;
@property (strong, nonatomic) NSString *sig;

@property (strong, nonatomic) NSString *movieDbApiKey;

@property (weak, nonatomic) IBOutlet UILabel *MovieTitle;
@property (weak, nonatomic) IBOutlet UIImageView *movieImage;

@end
