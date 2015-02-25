//
//  ViewControllerDictionary.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerDictionary.h"
#import "ViewControllerEditWord.h"

@interface ViewControllerDictionary ()

@end

@implementation ViewControllerDictionary

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {        
        // initiating Tap Gesture Recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer: tapGesture];

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // setting delegates
    self.textField.delegate = self;
    self.dictionaryTableView.delegate = self;
    self.dictionaryTableView.dataSource = self;
    
}

/*
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}
*/

// -- TableView --

// Number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Number of rows in sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [managedObjectsFromDictionary count];
}

// Performing actions to update the cell in tableview
-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [managedObjectsFromDictionary[indexPath.row] valueForKey: @"name"];
    if ([self.entityName isEqual: @"Word"])
        cell.detailTextLabel.text = [[managedObjectsFromDictionary[indexPath.row] valueForKey: @"definition"] string];
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // initialize new view controller
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    
    // setting selected word
    self.viewControllerEditWord.selectedWord = managedObjectsFromDictionary[indexPath.row];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
    [self presentViewController: NCvcEditWord animated: YES completion: nil];
}

// swipe to the left and deleting word
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // delete object from CoreData, MutableArray and tableview
    [self showMessageWithString: [NSString stringWithFormat: NSLocalizedString(@"%@ %@ removed", "Word or tag removed"), self.entityName, [managedObjectsFromDictionary[indexPath.row] valueForKey: @"name"]]];
    [self.managedObjectContext deleteObject: managedObjectsFromDictionary[indexPath.row]];
    [managedObjectsFromDictionary removeObjectAtIndex: indexPath.row];
    
    [self.dictionaryTableView beginUpdates];
    [self.dictionaryTableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
    [self.dictionaryTableView endUpdates];
    
    [self.managedObjectContext save: nil];
}

// Dismiss keyboard on tap
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Text Field
// Reloading data in tableview on typing in textfield
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: self.entityName inManagedObjectContext: self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // creating predicate
    NSMutableString *predicateString = [NSMutableString stringWithString: self.textField.text];
    if ([string isEqual: @""])
        [predicateString deleteCharactersInRange: range];
    else
        [predicateString appendString: string];
   
    // if length of string in textfiled is more than 2, then Core Data will search words with format "_wordPart_*", else all words in database
   if (predicateString.length > 2)
        predicateString = [NSMutableString stringWithFormat: @"name LIKE[c] '%@*'",  predicateString];
   else
        predicateString = [NSMutableString stringWithFormat: @"name LIKE[c] '*'"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    
    // setting FetchRequest
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    [request setSortDescriptors: sortDescriptors];
    [request setPredicate: predicate];
    managedObjectsFromDictionary = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest: request error: nil]];
    
    [self.dictionaryTableView reloadData];
    
    return YES;
}

-(void) showMessageWithString: (NSString *) string
{
    if ((messageHud != nil) && !(messageHud.hidden))
    {
        messageHud.labelText = string;
    }
    if (messageHud == nil)
    {
        messageHud = [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        
        // Configure for text only and offset down
        messageHud.mode = MBProgressHUDModeText;
        messageHud.delegate = self;
        messageHud.labelText = string;
        messageHud.margin = 10.f;
        messageHud.userInteractionEnabled = NO;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        // setting position. By default yOffset = 0, which means CENTER of the screen.
        // screenRect.size.height / 2 == bottom of the screen
        // screenRect.size.height / 3 == little bit higher
        messageHud.yOffset = screenRect.size.height / 3;
        [messageHud hide: YES afterDelay: 3];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [messageHud removeFromSuperview];
    //[messageHud release];
    messageHud = nil;
}

@end
