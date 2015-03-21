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
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.entityName = @"Word";
    self.textField.placeholder = @"Type a word...";
    
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
