//
//  ViewControllerWordsWithTag.m
//  MyDictionary
//
//  Created by robert on 11/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerWordsWithTag.h"
#import "Tag.h"

@interface ViewControllerWordsWithTag ()

@end

@implementation ViewControllerWordsWithTag

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Left button on navigation controller
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(back)];
        leftBarButtonItem.tintColor = [UIColor colorWithRed:208/255.0 green:237/255.0 blue:244/255.0 alpha:1.0];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.entityName = @"Word";
    
    NSLog(@"%@", self.selectedTag.name);
    // changing position of textfield and tableview
    [self.navigationItem setTitle:self.selectedTag.name];
    self.textField.center = CGPointMake(self.textField.center.x, self.textField.center.y + 30);
    self.dictionaryTableView.center = CGPointMake(self.dictionaryTableView.center.x, self.dictionaryTableView.center.y + 30);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.selectedTag.name;
    
    self.managedObjectsFromDictionary = [NSMutableArray arrayWithArray:[self.selectedTag.words allObjects]];
    
    self.managedObjectContext = self.selectedTag.managedObjectContext;
    
    // reloading data
    [self.dictionaryTableView reloadData];
    
    // setting navigation bar and status bar color
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0];
}

-(void)viewWillLayoutSubviews
{
    self.textFieldConteiner.frame = CGRectMake(0,
                                               -20,
                                               self.textFieldConteiner.frame.size.width,
                                               self.textFieldConteiner.frame.size.height);
    self.textField.frame = CGRectMake(self.textField.frame.origin.x,
                                      28,
                                      self.textField.frame.size.width,
                                      self.textField.frame.size.height);
    self.dictionaryTableView.frame = CGRectMake(0,
                                                self.textFieldConteiner.frame.origin.y + self.textFieldConteiner.frame.size.height,
                                                self.dictionaryTableView.frame.size.width,
                                                self.dictionaryTableView.frame.size.height);
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
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '%@*' AND ANY tags.name LIKE[c] '%@'",  predicateString, self.selectedTag.name];
    else
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '*' AND ANY tags.name LIKE[c] '%@'", self.selectedTag.name];
    
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

// Back to prev view
- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
