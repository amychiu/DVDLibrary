//
//  DetailViewController.m
//  DVDLibrary
//
//  Created by Ming on 2/28/14.
//  Copyright (c) 2014 Ming. All rights reserved.
//
// DetailViewController appears when a movie is tapped on in the LibraryViewController
// and displays details about the movie.  It also contains a trailer button that segues
// to the WebViewController with a YouTube link of the movie.

#import "DetailViewController.h"
#import "Movie.h"
#import "WebViewController.h"
#import "MovieLibraryManager.h"
#import "Reachability.h"
#import "ProcessingView.h"

@interface DetailViewController ()
@property (strong, nonatomic) ProcessingView *processingView;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

    // set up sections for table view
    [self setUpSectionedData];
    
    // set the image and title
    self.movieImageView.image = self.movie.image;
    self.titleLabel.text = self.movie.title;
    
    self.tableView.sectionFooterHeight = 0.0;
    
    // set up busy processing spinner
    self.processingView = [[ProcessingView alloc] initWithFrame:CGRectMake(110, 200, 100, 100)withMessage:@"Deleting"];
    [self.view addSubview:self.processingView];
    self.processingView.hidden = YES;
    
    // if no movie trailer, disable button and change to disabled view
    if (self.movie.trailer == nil){
        self.trailerButton.backgroundColor = [UIColor darkGrayColor];
        self.trailerButton.enabled = NO;
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* sectionTitle = [self.sections objectAtIndex:section];
    return sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 3;
    
    // Don't count or show section if it is empty
    for (NSString *section in self.sections){
        if (!([(NSArray*)[self.sectionedData objectForKey:section] count] > 0)){
            count--;
        }
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* category = [self.sections objectAtIndex:section];
    NSArray* arrayForSection = (NSArray*)[self.sectionedData objectForKey:category];
    
    // Limit number of cast members shown to 10
    if ([category isEqualToString:@"Cast"] && [self.movie.cast count]>10)
        return 10;
    else
        return [arrayForSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCellID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Get text for current position
    NSString* category = [self.sections objectAtIndex:indexPath.section];
    NSArray* arrayForSection = (NSArray*)[self.sectionedData objectForKey:category];
    
    // Configure cell appearance
    cell.textLabel.text = [arrayForSection objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    // Setup label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *string = [self.sections objectAtIndex:section];
    [label setText:string];
    [view addSubview:label];
    
    [view setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.7f]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Set cell size for synopsis to fit synopsis text
    if (indexPath.section==1 & indexPath.row==0)
    {
        CGRect rect = [self.movie.description boundingRectWithSize:CGSizeMake(260.f, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                                             context:nil];
        CGSize strSize = rect.size;
        return (strSize.height);
    }
    else return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // If no items in section, don't show any header
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return 25;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navigation

/********************************************************************************************
 * @method watchTrailer:
 * @abstract performs segue to trailer
 * @description
 ********************************************************************************************/
- (IBAction)watchTrailer:(id)sender {
    NSLog(@">>>>> Trailer button tapped");
    if (self.movie.trailer != nil){
        [self performSegueWithIdentifier: @"TrailerSegue" sender: self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self isReachable]) {
        if ([[segue identifier] isEqualToString:@"TrailerSegue"]) {
        
            NSLog(@">>>>> Segue from DetailViewController to WebViewController");
            
            // Get destination view
            WebViewController *wvc = [segue destinationViewController];
            
            // Set the trailer url in the new view
            wvc.trailerURL = self.movie.trailer;
        }
    }
    else{
        [self noInternetError];
    }
}

#pragma mark - Movie Deletion

/********************************************************************************************
 * @method deleteMovie
 * @abstract deletes the current movie showing in the detail view
 * @description removes the item and resaves the new library in the plist
 ********************************************************************************************/
- (IBAction)deleteMovie:(UIBarButtonItem *)sender {
    NSLog(@">>>>> Trash can button clicked");
    self.processingView.hidden = NO;
    
    [self.allMovieData removeObject:self.movie];

    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
        
    dispatch_async(queue,^{
        MovieLibraryManager *plistManager = [MovieLibraryManager sharedInstance];
        [plistManager saveMovieLibrary:self.allMovieData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeMovieSuccess];
        });
    });

}

/********************************************************************************************
 * @method removeMovieSuccess
 * @abstract gives alert view when the movie is successfully deleted from the library
 * @description
 ********************************************************************************************/
- (void)removeMovieSuccess
{
    self.processingView.hidden = YES;
    NSString *title = @"Movie successfully deleted!";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:title delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    NSLog(@">>>>> Movie successfully deleted alert");
    
}

/********************************************************************************************
 * @method alertView clickedButtonAtIndex:
 * @abstract action when the successful deletion "OK" button is clicked
 * @description after the delete movie success, the user is taken back to the library page
 *      when OK is clicked
 ********************************************************************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        NSLog(@">>>>> OK button clicked on successful deletion");
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

#pragma mark - Reachability

/********************************************************************************************
 * @method isReachable
 * @abstract checks to see if have wifi or 3G/LTE connection
 * @description Uses the Reachability classes
 ********************************************************************************************/
- (BOOL)isReachable
{
    Reachability *currentReachability = [Reachability reachabilityForInternetConnection];
    if(currentReachability.currentReachabilityStatus != NotReachable){
        NSLog(@">>>>>Connected to the internet!");
        return true;
    }
    NSLog(@">>>>>Not connected to the internet!");
    return false;
}

/********************************************************************************************
 * @method noInternetError
 * @abstract gives alert view error when not connected to internet to search
 * @description
 ********************************************************************************************/
- (void)noInternetError
{
    NSString *title = @"Sorry! Must be connected to the internet to view the trailer!";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    NSLog(@"Showing no internet connection alert");
}

#pragma mark

/********************************************************************************************
 * @method setUpSectionedData
 * @abstract sets up sections for table view
 * @description
 ********************************************************************************************/
- (void) setUpSectionedData{
    self.sections = [[NSMutableArray alloc] initWithObjects:@"Movie Info",@"Synopsis",@"Cast", nil];
    self.sectionedData = [[NSMutableDictionary alloc] init];
    
    // Movie info
    NSMutableArray *sectionData1 = [[NSMutableArray alloc] init];
    if (self.movie.duration != nil){
        [sectionData1 addObject:[NSString stringWithFormat:@"Runtime: %@ minutes",self.movie.duration]];
    }
    if (self.movie.releaseDate != nil){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *release = [dateFormatter stringFromDate:self.movie.releaseDate];
        [sectionData1 addObject: [NSString stringWithFormat:@"Release Date: %@",release]];
    }
    if (![self.movie.genre isEqualToString:@""]){
        [sectionData1 addObject:[NSString stringWithFormat:@"Genres: %@",self.movie.genre]];
    }
    [self.sectionedData setValue:sectionData1 forKey:@"Movie Info"];
    
    // Synopsis
    NSArray *sectionData2 = @[self.movie.description];
    [self.sectionedData setValue:sectionData2 forKey:@"Synopsis"];
    
    // Cast
    if ([self.movie.cast count] > 0){
        [self.sectionedData setValue:self.movie.cast forKey:@"Cast"];
    }
}
@end
