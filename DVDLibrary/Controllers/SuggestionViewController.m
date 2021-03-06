//
//  SuggestionViewController.m
//  DVDLibrary
//
//  Created by Ming on 3/1/14.
//  Copyright (c) 2014 Ming. All rights reserved.
//
// SuggestionViewController shows a UIPickerView with a spin button.
// When the user spins, the picker animates spinning to a random
// movie and an alert view displays the selected movie to the user.

#import "SuggestionViewController.h"
#import "MovieData.h"
#import "Movie.h"
#import "MovieLibraryManager.h"

@interface SuggestionViewController ()
@property (strong, nonatomic) NSArray *movieArray;
@end

@implementation SuggestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //read data from plist
    MovieLibraryManager *plistManager = [MovieLibraryManager sharedInstance];
    self.movieArray = [plistManager getMovieLibrary];
    
    // if empty library, disable spin button
    if (!([self.movieArray count]>0)){
        self.spinButton.enabled = NO;
    } else {
        // Double array if under 50 movies in collection
        if ([self.movieArray count] < 50) {
             self.movieArray =[self.movieArray arrayByAddingObjectsFromArray:self.movieArray];
        }
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.movieArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Movie *movie = [self.movieArray objectAtIndex:row];
    return movie.title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, pickerView.frame.size.width-50, 44)];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    Movie *movie = [self.movieArray objectAtIndex:row];
    label.text = movie.title;

    return label;
}

/*******************************************************************************
 * @method      spin:
 * @abstract
 * @description When spin button tapped, animation begins picking a random
                movie in the spinner and displays alert after movie selected.
 ******************************************************************************/
- (IBAction)spin:(id)sender {
    
    NSLog(@">>>>> Spin button tapped");
    
    // Don't allow spin button to be tapped while spinning
    [self.spinButton setEnabled:NO];

    // Create crazy animation of picking random movies
    [self performSelector: @selector(pickRandomRow)
               withObject: nil
               afterDelay: 0];
    [self performSelector: @selector(showSelectedMovie)
               withObject: nil
               afterDelay: 0.5];
}

/*******************************************************************************
 * @method      pickRandomRow
 * @abstract    Animates picking random row in UIPickerView
 * @description
 ******************************************************************************/
-(void)pickRandomRow
{
    [self.picker selectRow: (arc4random() % [self.movieArray count]) inComponent: 0 animated: YES];
}

/*******************************************************************************
 * @method      showSelectedMovie
 * @abstract
 * @description Shows an alert with the selected movie and enables spin button
 ******************************************************************************/
-(void)showSelectedMovie
{
    NSLog(@">>>>> Selected movie alert shown");
    
    // Get selected movie
    Movie *movie = (Movie*)[self.movieArray objectAtIndex:[self.picker selectedRowInComponent:0]];
    
    // Display an alert with the selected movie
    NSString *movieTitle = movie.title;
    NSString *title = [[NSString alloc] initWithFormat:@"Time to watch %@!", movieTitle];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
    // Allow user to spin again
    [self.spinButton setEnabled:YES];
}

@end
