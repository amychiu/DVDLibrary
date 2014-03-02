//
//  MovieCollectionViewController.m
//  DVDLibrary
//
//  Created by Ming on 2/27/14.
//  Copyright (c) 2014 Ming. All rights reserved.
//

#import "MovieCollectionViewController.h"
#import "MovieCollectionViewCell.h"
#import "Movie.h"
#import "MovieData.h"

@interface MovieCollectionViewController ()

@end

@implementation MovieCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     self.allTableData = [[MovieData alloc] init].movieData;
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
    return [self.allTableData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    static NSString *identifier = @"MovieCollectionViewCellID";
    MovieCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Get movie at current position
    Movie *movie = [[Movie alloc] init];
   // NSString* category = [self.sections objectAtIndex:indexPath.section];
    //NSArray* arrayForSection = (NSArray*)[self.filteredTableData objectForKey:category];
    
    movie = self.allTableData[indexPath.row];
    
    UIImage *image = movie.image;
    
//    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://icondock.com/wp-content/uploads/2009/03/easter-icons.jpg"]]];
   
    [cell.movieImageView setImage:image];
    return cell;
    
}

//- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
//                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"MovieCollectionViewCellID";
//    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    Movie *movie = [self.movies objectAtIndex:indexPath.row];
//
//    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://icondock.com/wp-content/uploads/2009/03/easter-icons.jpg"]]];
//    
//    [cell.movieImage setImage:image];
//    
//    return cell;
//
//}

#pragma mark – UICollectionViewDelegateFlowLayout


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(50,80);
//}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


@end
