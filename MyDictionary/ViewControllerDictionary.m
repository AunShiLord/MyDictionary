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
                                        UIGestureRecognizerDelegate,
                                        MBProgressHUDDelegate >

@end

@implementation ViewControllerDictionary

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // initiating Tap Gesture Recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(dismissKeyboard)];
        // REVIEW Разбить на строки.
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
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
    
    // initialize new view controller
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    self.viewControllerEditWord.deleteWordOnBack = NO;
    self.navigationControllerEditWord = [[UINavigationController alloc] initWithRootViewController:self.viewControllerEditWord];
    
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
    return [self.managedObjectsFromDictionary count];
}

// Performing actions to update the cell in tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
// REVIEW Не хватает пробелов. Лишние пробелы.
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        // REVIEW Это точно нужно? Как работает dequeueReusableCell?
        // ANSWER Кажется, все же нужно. dequeueReusableCell возвращает уже использованную
        // ANSWER ячейку, если такая существует с указанным идентифекатором.
        // ANSWER Но при первом обращении она возвращает nil, так как таких ячеек еще нет.
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSManagedObject *managedObject = self.managedObjectsFromDictionary[indexPath.row];
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    if ([self.entityName isEqual:@"Word"])
        cell.detailTextLabel.text = [[managedObject valueForKey:@"definition"] string];
    // REVIEW Зачем 2 раза запрашивать один и тот же словарь, если можно один
    // REVIEW один раз его запросить, а потом взять с него 2 раза значения?
    // ANSWER А что плохого брать значение из NSArray по индексу?
    // ANSWER Исправил, добавив дополнительную переменную.
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // setting selected word
    self.viewControllerEditWord.selectedWord = self.managedObjectsFromDictionary[indexPath.row];
    [self presentViewController:self.navigationControllerEditWord animated:YES completion:nil];
    // REVIEW Лишние пробелы. camelCase.
}

// swipe to the left and deleting word
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = self.managedObjectsFromDictionary[indexPath.row];
    // delete object from CoreData, MutableArray and tableview
    [self showMessageWithString:
     [NSString stringWithFormat:NSLocalizedString(@"%@ %@ removed", "Word or tag removed"), self.entityName, [managedObject valueForKey:@"name"]]];
    // REVIEW Зачем [NSString stringWithFormat]?
    // ANSWER Чтобы не париться с конкатенацией разных строк, пробелов и т.д.
    [self.managedObjectContext deleteObject: managedObject];
    [self.managedObjectsFromDictionary removeObjectAtIndex:indexPath.row];
    // REVIEW Опять несколько раз запрос словаря. Сделать запрос лишь раз.
    // ANSWER вроде бы испарвил.
    
    [self.dictionaryTableView beginUpdates];
    [self.dictionaryTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.dictionaryTableView endUpdates];
    
    [self.managedObjectContext save:nil];
}

// Dismiss keyboard on tap
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Text Field
// Reloading data in tableview on typing in textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Notification text did change to change first letter to uppercase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    // REVIEW Зачем подписываться каждый раз?
    // ANSWER Потому что ниже я каждый раз отписываюсь.
    // ANSWER Зачем отписываюсь объяснил ниже.
    
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
    // REVIEW Зачем каждый раз отписываться?
    // ANSWER Если не отписаться, метод будет вызываться несколько раз,
    // ANSWER так как в самом конце я опять меняю строку.
    // NSLog(@"Blabla");

    if (self.textField.text.length == 1)
        // check if first letter is not uppercase
        if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self.textField.text characterAtIndex:0]])
            // make first letter uppercase
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self.textField.text substringToIndex:1] uppercaseString]];

}

- (void)showMessageWithString:(NSString *)string
{
    if ((self.messageHud != nil) && !(self.messageHud.hidden))
    {
        self.messageHud.labelText = string;
    }
    if (self.messageHud == nil)
    {
        self.messageHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // REVIEW Почему бы сразу не создать?
        // REVIEW Почему не toast?
        // ANSWER На сколько я изучил MBProgressHUD, это самый удобный способ вывода.
        // ANSWER В демо приложении от авторов используется этот способ.
        // ANSWER На iOS вроде нет аналогов toast.
        // ANSWER Этот фреймворк выполянет функции toast и к нем много разных опций.
        
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

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self.messageHud removeFromSuperview];
    //[messageHud release];
    self.messageHud = nil;
}

@end
