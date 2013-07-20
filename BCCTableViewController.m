//
//  BCCTableViewController.m
//  Converter
//
//  Created by Briana Chapman on 3/31/13.
//  Copyright (c) 2013 Briana Chapman. All rights reserved.
//

#import "BCCTableViewController.h"

@interface BCCTableViewController ()

@end

/* Converting from USD to all the others should be localized to the user's local currency instead of always USD*/

@implementation BCCTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //initially the data is not ready until the notification is received from the model
    self.dataIsReady = NO;
    //initial amount is set to 1 to give useful information to the user
    self.amount = [NSNumber numberWithInt:1];
    //set up for receiving notification that the data is ready
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
   
    //in this case, the model cannot be lazily instantiated.
    if (!_converter){
        _converter = [[BCCConverterModel alloc] init];        
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //grab the text in the amountField
    NSString *text = self.amountField.text;
    //get the number from the text as a float
    float number = [text floatValue];
    //update the amount variable
    if (number == 0) {
        self.amount = [NSNumber numberWithInt:1];
    }else{
        self.amount = [NSNumber numberWithFloat:number];
    }
    //reload all the data in the table view once the 
    [self.tableView reloadData];
    
}

//since there is no done button with a number pad, dismissing happens with a tap to the background of the view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //text box resigns first responder (dismisses keyboard)
    [self.amountField resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.dataIsReady) {
        return [self.converter.currencyCodes count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"currencyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (self.dataIsReady) {
        // Configure the cell...
        //converting FROM united states dollars at all times on this tab
        self.converter.currentlySelectedCurrencyACode = @"USD";
        //converting TO the currency which corresponds to a given row. 
        self.converter.currentlySelectedCurrencyBCode = [self.converter.currencyCodes objectAtIndex:indexPath.row];
        //the text is set to the converted value
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.converter convertWithAmount:self.amount]];
        //the detail text is set to the name of the currency
        cell.detailTextLabel.text = [self.converter.currencyCodesAndNames objectForKey:[self.converter.currencyCodes objectAtIndex:indexPath.row]];
        //set the image of the cell to be the image coresponding to the currency
        cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[self.converter.currencyCodes objectAtIndex:indexPath.row] ofType:@"jpg" inDirectory:@"currency"]];
    }
    return cell;
}

//method for receiving the notification
- (void) receiveNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"TestNotification"]){
        //the data is now ready
        self.dataIsReady = YES;
        //reload the tableView
        [self.tableView reloadData];
        self.overlay.hidden = TRUE;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //when a row is selected, go to the detail view controller
    [self performSegueWithIdentifier:@"toDetailViewFromTableView" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //get the indexPath from the tableView
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //get the destinationViewController
    BCCDetailViewController *controller = segue.destinationViewController;
    //pass the model to the detail view
    controller.converter = self.converter;
    //pass the currency code to the detail view
    controller.currencyCodeOrigin = [self.converter.currencyCodes objectAtIndex:indexPath.row];
    //let the detail view know that it originated from the table view
    controller.cameFromTableView = YES;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}
- (void) dealloc
{
    //remove self as an observer so Notification Center doesn't continue to try and send notification objects to the deallocated object
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//unwind from the detail view controller 
- (IBAction)doneButtonPressed:(UIStoryboardSegue *)sender {
    return;
}

@end
