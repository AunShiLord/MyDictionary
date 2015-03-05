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
        // REVIEW Разбить на строки.
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer: tapGesture];
        // REVIEW Лишний пробел.
        
        // Notification text did change
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

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
// REVIEW Не хватает пробелов. Лишние пробелы.
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
        // REVIEW Это точно нужно? Как работает dequeueReusableCell?
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [managedObjectsFromDictionary[indexPath.row] valueForKey: @"name"];
    if ([self.entityName isEqual: @"Word"])
        cell.detailTextLabel.text = [[managedObjectsFromDictionary[indexPath.row] valueForKey: @"definition"] string];
    // REVIEW Зачем 2 раза запрашивать один и тот же словарь, если можно один
    // REVIEW один раз его запросить, а потом взять с него 2 раза значения?
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // initialize new view controller
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    // REVIEW Зачем при каждом выборе создавать? Достаточно сделать это
    // REVIEW лишь раз, а потом использовать повторно.
    
    // setting selected word
    self.viewControllerEditWord.selectedWord = managedObjectsFromDictionary[indexPath.row];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
    // REVIEW Тоже не нужно каждый раз создавать.
    // REVIEW Лишние пробелы. camelCase.
    [self presentViewController: NCvcEditWord animated: YES completion: nil];
    // REVIEW Лишние пробелы. camelCase.
}

// swipe to the left and deleting word
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // delete object from CoreData, MutableArray and tableview
    [self showMessageWithString: [NSString stringWithFormat: NSLocalizedString(@"%@ %@ removed", "Word or tag removed"), self.entityName, [managedObjectsFromDictionary[indexPath.row] valueForKey: @"name"]]];
    // REVIEW Зачем [NSString stringWithFormat]?
    [self.managedObjectContext deleteObject: managedObjectsFromDictionary[indexPath.row]];
    [managedObjectsFromDictionary removeObjectAtIndex: indexPath.row];
    // REVIEW Опять несколько раз запрос словаря. Сделать запрос лишь раз.
    
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
    // Notification text did change to change first letter to uppercase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    // REVIEW Зачем подписываться каждый раз?
    
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

// making first letter uppercase
-(void) textFieldDidChange: (NSNotification *)notification
{
    // removing observer from notification (to make sure it won't call twice)
    [[NSNotificationCenter defaultCenter] removeObserver: self name:  UITextFieldTextDidChangeNotification object: nil];
    // REVIEW Зачем каждый раз отписываться?

    if (self.textField.text.length == 1)
        // check if first letter is not uppercase
        if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember: [self.textField.text characterAtIndex: 0]])
            // make first letter uppercase
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self.textField.text substringToIndex:1] uppercaseString]];

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
        // REVIEW Почему бы сразу не создать?
        // REVIEW Почему не toast?
        
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
