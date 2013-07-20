//
//  BCCViewController.m
//  Converter
//
//  Created by Briana Chapman on 3/20/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import "BCCViewController.h"


@interface BCCViewController ()


@end

@implementation BCCViewController

//lazily instantiate the model so it's not being created unless it is needed.
- (BCCConverterModel*) converter
{
    if (!_converter){
        _converter = [[BCCConverterModel alloc] init];
        //set up notification so that the model sends a notification when the data is ready and the interface reloads when it is complete

    }
    return _converter;
}

//what happens when the view loads
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //notification from the Model that the data is ready to be displayed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"TestNotification"
                                               object:nil]; 
    //enable user interaction in both currency images so that the gesture recognizer will work
    self.fromImage.userInteractionEnabled = YES;
    self.toImage.userInteractionEnabled = YES;
    //setting bold font for the currency names for aesthetic reasons
    [self.fromCurrencyLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.toCurrencyLabel setFont:[UIFont boldSystemFontOfSize:15]];
}

//what happens when the notification from the model is received
- (void) receiveNotification:(NSNotification *)notification
{
    //reloading the UIPickerView components to reflect the data from the JSON feed
    [self.Picker reloadAllComponents];
    //setting the initial amount to 1 of the original currency
    self.amount = [NSNumber numberWithInt:1];
    
    [self resetToUSD]; 

    [self updateUIWithConvertedAmount];
    self.overlay.hidden = TRUE; 
    return;

}

//converts between the currencies using a method in the model and updates the user interface
- (void) updateUIWithConvertedAmount{
    //if there's no value in the text box, set it to one.
    if ([self.amountTextBox.text isEqualToString:@""]) {
        self.amount = [NSNumber numberWithFloat:1];
    }else{
        self.amount = [NSNumber numberWithFloat:[self.amountTextBox.text floatValue]];
    }
    //get the currently selected row of the UIPickerView and assign it to self.currentlySelectedRow
    self.currentlySelectedRowA = [NSNumber numberWithInteger:(long)[self.Picker selectedRowInComponent:0]];
    NSLog(@"row: %ld", (long)[self.Picker selectedRowInComponent:0]); 
    self.currentlySelectedRowB = [NSNumber numberWithInteger:(long)[self.Picker selectedRowInComponent:1]];
    
    //get the currency codes that correspond to the selected currencies
    self.converter.currentlySelectedCurrencyACode = [self.converter.currencyCodes objectAtIndex:[self.currentlySelectedRowA integerValue]];
    self.converter.currentlySelectedCurrencyBCode = [self.converter.currencyCodes objectAtIndex:[self.currentlySelectedRowB integerValue]];
    
    //use the converter (Model) to convert the currencies
    NSNumber *convertedAmount = [self.converter convertWithAmount:self.amount];
    
    //set the label to display the converted amount
    [self.convertedLabel setText:[NSString stringWithFormat:@"%@", convertedAmount]];
    
    //get the name of the currency user is converting FROM and display it in the from currency label
    [self.fromCurrencyLabel setText:[self.converter.currencyCodesAndNames objectForKey:self.converter.currentlySelectedCurrencyACode]];
    //get the name of the currency user is converting TO and display it in the to currency label
    [self.toCurrencyLabel setText:[self.converter.currencyCodesAndNames objectForKey:self.converter.currentlySelectedCurrencyBCode]];
    
    //setting the images which correspond to the currencies (named in the format CurrencyCode.jpg)
    [self.fromImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.converter.currentlySelectedCurrencyACode ofType:@"jpg" inDirectory:@"currency"]]];
    [self.toImage setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.converter.currentlySelectedCurrencyBCode ofType:@"jpg" inDirectory:@"currency"]]];
    
    //get currency symbol for original currency
    //findLocaleByCurrencyCode gets the locale information based on the currency code 
    NSLocale *lclA = [[NSLocale alloc] initWithLocaleIdentifier:[[self findLocaleByCurrencyCode:self.converter.currentlySelectedCurrencyACode] localeIdentifier]];
    NSNumberFormatter *fmtrA = [[NSNumberFormatter alloc] init];
    [fmtrA setNumberStyle:NSNumberFormatterCurrencyStyle];
    [fmtrA setLocale:lclA];
    //gets the currency symbol for the given locale
    NSString *currencySymbolA = [lclA displayNameForKey:NSLocaleCurrencySymbol value:self.converter.currentlySelectedCurrencyACode];
    //updates the currency label with the returned symbol
    self.currencySymbolALabel.text = currencySymbolA;
    
    //nearly the same as above^
    //get currency symbol for new currency
    NSLocale *lclB = [[NSLocale alloc] initWithLocaleIdentifier:[[self findLocaleByCurrencyCode:self.converter.currentlySelectedCurrencyBCode] localeIdentifier]];
    //findLocaleByCurrencyCode gets the locale information based on the currency code
    NSNumberFormatter *fmtrB = [[NSNumberFormatter alloc] init];
    [fmtrB setNumberStyle:NSNumberFormatterCurrencyStyle];
    [fmtrB setLocale:lclB];
    //gets the currency symbol for the given locale
    NSString *currencySymbolB = [lclB displayNameForKey:NSLocaleCurrencySymbol value:self.converter.currentlySelectedCurrencyBCode];
    //updates the currency label with the returned symbol
    self.currencySymbolBLabel.text = currencySymbolB;

}

//finds the locale information for a given currency code
- (NSLocale *) findLocaleByCurrencyCode:(NSString *)_currencyCode
{
    NSArray *locales = [NSLocale availableLocaleIdentifiers];
    NSLocale *locale = nil;
    NSString *localeId;
    
    //loops through all the locales to find the locale associated with the given currency code
    for (localeId in locales) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
        NSString *code = [locale objectForKey:NSLocaleCurrencyCode];
        if ([code isEqualToString:_currencyCode])
            break;
        else
            locale = nil;
    }
    
    // For some codes that locale cannot be found:
    if (locale == nil) {
        NSDictionary *components = [NSDictionary dictionaryWithObject:_currencyCode
                                                               forKey:NSLocaleCurrencyCode];
        
        localeId = [NSLocale localeIdentifierFromComponents:components];
        locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
    }
    return locale;
    //if the locale is still nil, the currency symbol will not be visible for very few currencies
}

- (void) dealloc
{
    //remove self as an observer so Notification Center doesn't continue to try and send notification objects to the deallocated object
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //set the number of rows in the component to be the same as the number of currencies we support (number of items in self.converter.currencyCodes
    return [self.converter.currencyCodes count];
}

//resets the left side of the picker to USD when USD button is tapped
- (IBAction)resetToUSD {
    //USD is in row 145 of the picker
    int index = 0;
    for (NSString *tempString in self.converter.currencyCodes) {
        if ([tempString isEqualToString:@"USD"]) {
            break; 
        }
        index++; 
    }
    [self.Picker selectRow:index inComponent:0 animated:YES];
    //update the currently selected ivar
    self.converter.currentlySelectedCurrencyACode = [self.converter.currencyCodes objectAtIndex:index];
    //update the user interface with the appropriate amounts. 
    [self updateUIWithConvertedAmount]; 

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //create two components in the UIPickerView
    return 2;
}
#pragma mark pickerViewDataSourceAndDelegateMethods 

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //get the component the row was selected in and update the corresponding variables
    if (component == 0) {
        self.currentlySelectedRowA = [NSNumber numberWithInt:row];
    }else{
        self.currentlySelectedRowB = [NSNumber numberWithInt:row];
    }
    
    //update the user interface with corresponding values
    [self updateUIWithConvertedAmount];

    return; 
 
}

//implemented this method to shrink the text size in the UIPickerView to fit more in
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties
        [tView.font fontWithSize:10];
    }
    // Fill the label text here
    [tView setText:[self.converter.currencyCodesAndNames objectForKey:[self.converter.currencyCodes objectAtIndex:row]]];
    return tView;
}

#pragma mark TextField delegate begins here
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //grab the text in the amountTextBox
    NSString *text = self.amountTextBox.text;
    //get the number from the text as a float
    float number = [text floatValue];
    //update the amount variable
    self.amount = [NSNumber numberWithFloat:number];
    //update the user interface
    [self updateUIWithConvertedAmount];
}

//since there is no done button with a number pad, dismissing happens with a tap to the background of the view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //text box resigns first responder (dismisses keyboard)
    [self.amountTextBox resignFirstResponder];
    //update self.amount with the number in the text box
    self.amount = [NSNumber numberWithFloat:[self.amountTextBox.text floatValue]];
    //update the user interface with all appropriate values
    [self updateUIWithConvertedAmount];
    
    //the following code handles taps to either of the images: 
    if ([[touches anyObject] view] == self.fromImage) {
        self.converter.origin = [NSNumber numberWithInt:0];
        
    }
    if ([[touches anyObject] view] == self.toImage) {
        self.converter.origin = [NSNumber numberWithInt:1];
    }    
}

//did not need to check the identifier of the segue in this case because instructions are the same regardless
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //create an instance of the destination view controller and pass it the instance of the model we are using
    BCCDetailViewController *controller = segue.destinationViewController;
    controller.converter = self.converter;
    controller.cameFromTableView = NO; 
}

//unwind from the detail view controller
- (IBAction)doneButtonPressed:(UIStoryboardSegue *)sender {
    return; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
