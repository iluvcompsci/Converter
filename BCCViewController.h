//
//  BCCViewController.h
//  Converter
//
//  Created by Briana Chapman on 3/20/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCCConverterModel.h"
#import "BCCDetailViewController.h"

@interface BCCViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *fromCurrencyLabel; //UILabel that shows which currency you are converting from
@property (weak, nonatomic) IBOutlet UILabel *toCurrencyLabel; //UILabel that shows which currency you are converting to
@property (weak, nonatomic) IBOutlet UITextField *amountTextBox; //UITextField that takes the amount of the original currency you are converting
@property (weak, nonatomic) IBOutlet UIPickerView *Picker; //UIPickerView which allows the user to select two currencies to convert between
@property (weak, nonatomic) IBOutlet UILabel *convertedLabel; //UILabel showing the converted value
@property (weak, nonatomic) IBOutlet UIImageView *fromImage; //UIImage containing an image of the currency the user is converting from
@property (weak, nonatomic) IBOutlet UIImageView *toImage; //UIImage containing an image of the currency the user is converting to
@property (weak, nonatomic) IBOutlet UIButton *dollarButton; //UIButton that snaps to US Dollars on the left side of the picker
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolALabel; //UILabel displaying the currency symbol for the currency user is converting from
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolBLabel; //UILabel
@property (strong, nonatomic) NSNumber *currentlySelectedRowA; //NSNumber which holds the index of the currently selected currency in the array self.converter.currencyCodes
@property (strong, nonatomic) NSNumber *currentlySelectedRowB; //NSNumber which holds the index of the currently selected currency in the array self.converter.currencyCodes
@property (strong, nonatomic) NSNumber *amount; //NSNumber which holds the amount to convert (user entered in the text box)
@property (strong, nonatomic) BCCConverterModel *converter; //holds an instance of the model to use throughout the app. 
@property (weak, nonatomic) IBOutlet UIImageView *overlay; //stops the user from interacting with the interface before the data is ready 


@end
