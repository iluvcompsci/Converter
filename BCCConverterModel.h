//
//  BCCConverter.h
//  Converter
//
//  Created by Briana Chapman on 3/23/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCCConverterModel : NSObject
@property (strong, nonatomic) NSString *currentlySelectedCurrencyACode;//currency code for the currently selected item
@property (strong, nonatomic) NSString *currentlySelectedCurrencyBCode;//currency code for the currently selected item 
@property (strong, nonatomic) NSDictionary *currentRates; //a dictionary of all the current rates for every currency
@property (strong, nonatomic) NSArray *currencyCodes; //an array of all the currency codes
@property (strong, nonatomic) NSDictionary *currencyCodesAndNames; //a dictionary of the codes and names
@property (strong, nonatomic) NSNumber *origin; //this holds the origin for the detail view controller, when it comes from the converter tab. 


- (NSNumber *) convertWithAmount:(NSNumber *)amount;



@end
