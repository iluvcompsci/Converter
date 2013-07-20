//
//  BCCTableViewController.h
//  Converter
//
//  Created by Briana Chapman on 3/31/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCCConverterModel.h"
#import "BCCDetailViewController.h"

@interface BCCTableViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BCCConverterModel *converter;// holds an instance of the model
@property (weak, nonatomic) IBOutlet UITextField *amountField; //holds takes an amount to convert from the user
@property (weak, nonatomic) IBOutlet UITableView *tableView; //tableView holds currencies and their conversion rates to USD
@property (strong, nonatomic) NSNumber *amount; //holds the amount from the amountField
@property (weak, nonatomic) IBOutlet UIImageView *overlay;//stops user from interacting with user interface before data is ready
@property (readwrite, nonatomic) BOOL dataIsReady; //stores whether it's ok to try and access data from the model
@end
