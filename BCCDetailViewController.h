//
//  BCCDetailViewController.h
//  Converter
//
//  Created by Briana Chapman on 3/22/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCCConverterModel.h"

@interface BCCDetailViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *largeCurrencyImage; //UIImage of the currency which goes across the entire screen
@property (weak, nonatomic) IBOutlet UIWebView *wikipediaWebView; //UIWebView which loads a relevant wikipedia page about the currency
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton; //button allowing the user to dismiss the modal view controller
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar; //displays the title of the currency and holds the done button
@property (strong, nonatomic) BCCConverterModel *converter; //the instance of the model passed from the view controller
@property (strong, nonatomic) NSNumber *origin; //holds image that the tap came from; 0 if left image, 1 if right image.
@property (strong, nonatomic) NSString *currencyCodeOrigin;
@property (readwrite, nonatomic) BOOL cameFromTableView; 
@end
