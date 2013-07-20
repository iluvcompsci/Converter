//
//  BCCConverter.m
//  Converter
//
//  Created by Briana Chapman on 3/23/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import "BCCConverterModel.h"
@interface BCCConverterModel ()
- (void)nowHaveCurrencyNames:(NSData *)currencyNames;
- (void)getCurrencyRates;
- (void)nowHaveCurrencyRates:(NSData *)currencyRates;

@end

@implementation BCCConverterModel


- (id)init {
    //when the model is initialized, it will process a JSON feed to get current conversion rates. 
    self = [super init];
    if (self) {
        //URL for getting all the names of the currencies and their currency codes
        NSURL *currencyNameURL = [NSURL URLWithString:@"http://openexchangerates.org/api/currencies.json?app_id=e84418382bd6409aa2a0a9270ddc94d2"];
        //get the JSON in a separate thread so as to leave the UI operable 
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        //@TODO: IF THE NETWORK IS DOWN OR SLOW, THIS MIGHT CRASH BECAUSE THE PICKER VIEW DOES NOT HAVE DATA
        dispatch_async(globalQueue, ^{
            //store the JSON data in currencyNames
            NSData *currencyNames = [NSData dataWithContentsOfURL:currencyNameURL];
            
            //now go to nowHaveCurrencyNames
            [self performSelectorOnMainThread:@selector(nowHaveCurrencyNames:)
                                   withObject:currencyNames waitUntilDone:YES];
        });
        
    }
    return self;
}

//this method will convert an amount between two currently selected currencies
- (NSNumber *) convertWithAmount:(NSNumber *)amount
{
   //gets the rates in terms of United States dollars
    NSNumber *rateFromUSD = [self.currentRates objectForKey:self.currentlySelectedCurrencyACode];
    NSNumber *rateToUSD = [self.currentRates objectForKey:self.currentlySelectedCurrencyBCode];
    
    NSLog(@"Conversion from %@ (%@ USD) to %@ (%@ USD)", self.currentlySelectedCurrencyACode, rateFromUSD, self.currentlySelectedCurrencyBCode, rateToUSD);
    // my conversion method uses the rates in terms of USD to get the currencies in terms of each other.
    
    // take input and divide by rateFromUSD and multiply by rateToUSD
    float converted = ([amount doubleValue]/[rateFromUSD doubleValue]) * [rateToUSD doubleValue];
    
    //returns the converted amount as an NSNumber
    return [NSNumber numberWithFloat: converted];
    
}

- (void)nowHaveCurrencyNames:(NSData *)currencyNames {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:currencyNames
                          
                          options:kNilOptions
                          error:&error];
    self.currencyCodesAndNames = json;
    //now that we have the currency names, get the currency rates
    
    self.currencyCodes = [json allKeys];
    self.currencyCodes = [self.currencyCodes sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    //move on to getCurrencyRates
    [self getCurrencyRates];
    
    
    
}

- (void)getCurrencyRates
{
    //the URL for getting the currency rates
    NSURL *currencyRateURL = [NSURL URLWithString:@"http://openexchangerates.org/api/latest.json?app_id=e84418382bd6409aa2a0a9270ddc94d2"];
    //do this in another thread so the UI doesn't get locked up. 
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(globalQueue, ^{
        NSData *currencyRates = [NSData dataWithContentsOfURL:currencyRateURL];
        //move on to nowHaveCurrencyRates
        [self performSelectorOnMainThread:@selector(nowHaveCurrencyRates:)
                               withObject:currencyRates waitUntilDone:YES];
    });
}

- (void)nowHaveCurrencyRates:(NSData *)currencyRates {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:currencyRates
                          
                          options:kNilOptions
                          error:&error];
    
    NSDictionary* latestRates = [json objectForKey:@"rates"];
    self.currentRates = latestRates;
    //post the notification to tell whoever is waiting on the data that it is now ready. 
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];

}



@end
