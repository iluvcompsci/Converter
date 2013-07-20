//
//  BCCDetailViewController.m
//  Converter
//
//  Created by Briana Chapman on 3/22/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import "BCCDetailViewController.h"

@interface BCCDetailViewController ()

@end

@implementation BCCDetailViewController

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
    //if the detail view came from the converter tab, then we need to know which image it came from. If it came from the table view, the currency code is passed in. 
    if (!self.cameFromTableView) {
        if ([self.converter.origin intValue] == 0) {
            self.currencyCodeOrigin = self.converter.currentlySelectedCurrencyACode;
        }
        if ([self.converter.origin intValue] == 1) {
            NSLog(@"self.origin is 1");
            self.currencyCodeOrigin = self.converter.currentlySelectedCurrencyBCode;
        }
    }
    //pull up the relevant wikipedia page
    [self loadWikipediaPage:[self.converter.currencyCodesAndNames objectForKey:self.currencyCodeOrigin]];
    //get the image from the currency code origin
    [self.largeCurrencyImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.currencyCodeOrigin ofType:@"jpg" inDirectory:@"currency"]]];
    //set the title corresponding to the currency code
    self.navBar.topItem.title = [self.converter.currencyCodesAndNames objectForKey:self.currencyCodeOrigin];

}

- (void)loadWikipediaPage:(NSString *)searchTerm{
    //create an array of the words in the currency name
    NSArray *array = [searchTerm componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    //make an empty string to start off the URL component which represents the search terms
    NSString *urlComponent = @"";
    
    for (NSString *tempString in array) {
        NSString *bareString = tempString;
        //find and replace all special characters for the search term because the wikipedia url does not accept special characters
        bareString = [bareString stringByReplacingOccurrencesOfString:@"ó" withString:@"o"];
        bareString = [bareString stringByReplacingOccurrencesOfString:@"ã" withString:@"a"];
        bareString = [bareString stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
        bareString = [bareString stringByReplacingOccurrencesOfString:@"í" withString:@"i"];
        bareString = [bareString stringByReplacingOccurrencesOfString:@"-" withString:@"+and+"];
        bareString = [bareString stringByReplacingOccurrencesOfString:@"ʻ" withString:@"'"];
        //create the component of the url that holds the search terms
        urlComponent = [urlComponent stringByAppendingString:[NSString stringWithFormat:@"%@+", bareString]];
    }
   //get rid of the extra "+" on the end of the search term
    urlComponent = [urlComponent substringToIndex:[urlComponent length]-1];
    
    //create the full URL with the component included in the appropriate place
    NSString *urlString = [NSString stringWithFormat:@"http://wikipedia.org/search-redirect.php?family=wikipedia&search=%@&language=en", urlComponent];
    //load up the URL in the webView
    [self.wikipediaWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
