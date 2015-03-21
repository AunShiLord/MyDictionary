//
//  ViewControllerDictionary.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerDictionary.h"
#import "ViewControllerEditWord.h"
#import "Word.h"
#import "MBProgressHUD.h"

@interface ViewControllerDictionary () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        UITextFieldDelegate,
                                        MBProgressHUDDelegate>


@end

@implementation ViewControllerDictionary

#pragma mark - System methods

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // initiating Tap Gesture Recognizer
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(dismissKeyboard)];
        self.tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:self.tapGesture];
        
        // notification on keyboard did hide
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];

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
    
    // initialize new view controller
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    self.viewControllerEditWord.deleteWordOnBack = NO;
    self.navigationControllerEditWord = [[UINavigationController alloc] initWithRootViewController:self.viewControllerEditWord];
    
}

#pragma mark - Tableview methods

// Number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Number of rows in sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.managedObjectsFromDictionary count];
}

// Performing actions to update the cell in tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSManagedObject *managedObject = self.managedObjectsFromDictionary[indexPath.row];
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    if ([self.entityName isEqual:@"Word"])
        cell.detailTextLabel.text = [[managedObject valueForKey:@"definition"] string];
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting selected word
    self.viewControllerEditWord.selectedWord = self.managedObjectsFromDictionary[indexPath.row];
    [self presentViewController:self.navigationControllerEditWord animated:YES completion:nil];
}

// swipe to the left and deleting word
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = self.managedObjectsFromDictionary[indexPath.row];
    // delete object from CoreData, MutableArray and tableview
    [self showMessageWithString:
     [NSString stringWithFormat:NSLocalizedString(@"%@ %@ removed", "Word or tag removed"), self.entityName, [managedObject valueForKey:@"name"]]];
    [self.managedObjectContext deleteObject: managedObject];
    [self.managedObjectsFromDictionary removeObjectAtIndex:indexPath.row];
    
    [self.dictionaryTableView beginUpdates];
    [self.dictionaryTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.dictionaryTableView endUpdates];
    
    [self.managedObjectContext save:nil];
}

#pragma mark - Text Field methods

// Switching gesture recognizer to cancel all events in view
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // taping on table view will close keyboard instead of opening the cell.
    // see also
    self.tapGesture.cancelsTouchesInView = YES;
}

// Reloading data in tableview on typing in textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Notification text did change to change first letter to uppercase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // creating predicate
    NSMutableString *predicateString = [NSMutableString stringWithString:self.textField.text];
    if ([string isEqual:@""])
        [predicateString deleteCharactersInRange:range];
    else
        [predicateString appendString:string];
   
    // if length of string in textfiled is more than 2, then Core Data will search words with format "_wordPart_*", else all words in database
   if (predicateString.length > 2)
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '%@*'",  predicateString];
   else
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '*'"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    // setting FetchRequest
    [request setEntity:entity];
    [request setIncludesPropertyValues:YES];
    [request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    self.managedObjectsFromDictionary = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:nil]];
    
    [self.dictionaryTableView reloadData];
    
    return YES;
}

// making first letter uppercase
- (void)textFieldDidChange:(NSNotification *)notification
{
    // removing observer from notification (to make sure it won't call twice)
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UITextFieldTextDidChangeNotification object:nil];

    if (self.textField.text.length == 1)
        // check if first letter is not uppercase
        if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self.textField.text characterAtIndex:0]])
            // make first letter uppercase
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self.textField.text substringToIndex:1] uppercaseString]];

}

#pragma mark - Custom methods
// Dismiss keyboard on tap and make view catch events again
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// allow view to catch touches when keyboard is down
-(void)keyboardDidHide
{
    self.tapGesture.cancelsTouchesInView = NO;
}

// Show message in hud
- (void)showMessageWithString:(NSString *)string
{
    if ((self.messageHud != nil) && !(self.messageHud.hidden))
    {
        self.messageHud.labelText = string;
    }
    if (self.messageHud == nil)
    {
        self.messageHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        self.messageHud.mode = MBProgressHUDModeText;
        self.messageHud.delegate = self;
        self.messageHud.labelText = string;
        self.messageHud.margin = 10.f;
        self.messageHud.userInteractionEnabled = NO;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        // setting position. By default yOffset = 0, which means CENTER of the screen.
        // screenRect.size.height / 2 == bottom of the screen
        // screenRect.size.height / 3 == little bit higher
        self.messageHud.yOffset = screenRect.size.height / 3;
        [self.messageHud hide:YES afterDelay:3];
    }
}

#pragma mark - MBProgressHUD delegete
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self.messageHud removeFromSuperview];
    //[messageHud release];
    self.messageHud = nil;
}

@end
