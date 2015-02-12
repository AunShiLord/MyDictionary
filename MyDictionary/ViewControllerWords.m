//
//  ViewControllerWords.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 12/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerWords.h"

@interface ViewControllerWords ()

@end

@implementation ViewControllerWords

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.entityName = @"Word";
    self.textField.placeholder = @"Type a word...";
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: self.entityName inManagedObjectContext: self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // creating predicate
    NSMutableString *predicateString = [NSMutableString stringWithString: self.textField.text];
    
    // if length of string in textfiled is more than 2, then Core Data will search words with format "_wordPart_*", else all words in database
    if (predicateString.length > 2)
        predicateString = [NSMutableString stringWithFormat: @"name LIKE[c] '%@*'",  self.textField.text];
    else
        predicateString = [NSMutableString stringWithFormat: @"name LIKE[c] '*'"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    
    // setting request attributes
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    [request setSortDescriptors: sortDescriptors];
    [request setPredicate: predicate];
    
    // executing request
    managedObjectsFromDictionary = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest: request error: nil]];
    
    // reloading data
    [self.dictionaryTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
