//
//  SearchViewController.m
//  DVDLibrary
//
//  Created by Amy Chiu on 3/2/14.
//  Copyright (c) 2014 Ming. All rights reserved.
//

#import "SearchViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "Movie.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.roviApiKey = @"rc3sf8efxtuv28kf9rj6gbwv";
    self.movieDbApiKey = @"a9dc5652da0de21c8fbd3004a590931b";
    self.foundMovie = [[Movie alloc]init];
    NSString *upc = @"043396399778";
    self.foundMovie.upc = upc;
    [self searchForMovieByUpc:upc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//downloads the json name from the website and adds query term to user defaults
- (void)searchForMovieByUpc: (NSString *)upcSymbol
{
    //gets json query results
    NSString *query = [NSString stringWithFormat:@"http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=F4F91C0E-E947-43C4-A649-7D4DE9C08044&upc=%@", upcSymbol];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:query]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                NSError *errorJson = nil;
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
                // Update the Nsmutable Array
                self.upcMovieResults = [[results mutableCopy] objectForKey:@"0"];
                NSString *title = (NSString *)[self.upcMovieResults objectForKey:@"productname"];
                NSRange range = [title rangeOfString:@"("];
                title = [title substringToIndex:range.location];
                self.foundMovie.title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSString *imageURL = (NSString *)[self.upcMovieResults objectForKey:@"imageurl"];
                self.foundMovie.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                
                [self searchForMovieByTitle:self.foundMovie.title];
                [self getMovieID:self.foundMovie.title];
                
                
            }] resume];
}

//searches a movie by title
- (void)searchForMovieByTitle: (NSString *)movieTitle
{
    self.sig = [self md5ConversionToSig];
    NSString *searchableTitle = [movieTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    //gets json query results
    NSString *query = [NSString stringWithFormat:@"http://api.rovicorp.com/search/v2.1/amgvideo/search?apikey=%@&sig=%@&query=%@&entitytype=movie&size=1&format=json&upcid=%@&include=all", self.roviApiKey, self.sig, searchableTitle, self.foundMovie.upc];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:query]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                NSError *errorJson = nil;
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
                // Update the Nsmutable Array
                self.titleMovieResults = [[results mutableCopy] objectForKey:@"searchResponse"];
                NSMutableDictionary *result = [[self.titleMovieResults objectForKey:@"results"] objectAtIndex:0];
                self.movieInfo = [result objectForKey:@"movie"];
                

                // Refresh the table on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.MovieTitle.text = self.foundMovie.title;
                    [self.movieImage setImage:self.foundMovie.image];
                    
                    
                });
                
            }] resume];
}


//method to do a sig conversion to access rovi api
- (NSString *) md5ConversionToSig
{
    
    NSString *sharedSecret = @"rQm5PPRUjg";
    
    int unixtime = [[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] integerValue];
    NSString *time = [NSString stringWithFormat:@"%d", unixtime];
    
    NSArray *stringsToConvert = [[NSArray alloc] initWithObjects:self.roviApiKey, sharedSecret, time, nil];
    NSString *concatenatedString = [stringsToConvert componentsJoinedByString:@""];
    
    const char *cStr = [concatenatedString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output.lowercaseString;
}


- (void)getMovieID: (NSString *)movieTitle
{
    NSString *searchableTitle = [movieTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    //gets json query results
    NSString *movieQuery = [NSString stringWithFormat:@"http://api.themoviedb.org/3/search/movie?api_key=%@&query=%@", self.movieDbApiKey, searchableTitle];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:movieQuery]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                NSError *errorJson = nil;
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
                // Update the Nsmutable Array
                NSMutableArray *movieTitleInfo = [[results mutableCopy] objectForKey:@"results"];
                NSMutableDictionary *result = [movieTitleInfo objectAtIndex:0];
                
                self.foundMovie.synopsis = [result objectForKey:@"synopsis"];
                
                self.foundMovie.movieDbId = (NSString *)[result objectForKey:@"id"];
                [self getImdbID:self.foundMovie.movieDbId];
                
            }] resume];
}

- (void)getImdbID:(NSString *)movieDbId
{
    //gets json query results
    NSString *movieQuery = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", movieDbId, self.movieDbApiKey];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:movieQuery]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                NSError *errorJson = nil;
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                
                // Update the Nsmutable Array
                NSMutableDictionary *result = [results mutableCopy];
                
                //imdb id
                self.foundMovie.imdbDbId = [result objectForKey:@"imdb_id"];
                
                //set movie's url
                NSString *imdbUrl = @"http://www.imdb.com/title/";
                imdbUrl = [imdbUrl stringByAppendingString:self.foundMovie.imdbDbId];
                self.foundMovie.url = [NSURL URLWithString:imdbUrl];
                
                NSMutableArray *genreResults = [result objectForKey:@"genres"];
                self.foundMovie.genre = [[NSMutableArray alloc]init];
                for (NSDictionary *genre in genreResults) {
                    NSString *category = [genre objectForKey:@"name"];
                    [self.foundMovie.genre addObject:category];
                }
                
                
                
            }] resume];
}

@end
