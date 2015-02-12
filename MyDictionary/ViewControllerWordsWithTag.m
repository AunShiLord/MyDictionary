//
//  ViewControllerWordsWithTag.m
//  MyDictionary
//
//  Created by robert on 11/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerWordsWithTag.h"

@interface ViewControllerWordsWithTag ()

@end

@implementation ViewControllerWordsWithTag

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Left button on navigation controller
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: self action: @selector(back)]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.selectedTag.name);
    [self.navigationItem setTitle: self.selectedTag.name];
    self.textField.center = CGPointMake(self.textField.center.x, self.textField.center.y + 30);
    self.dictionaryTableView.center = CGPointMake(self.dictionaryTableView.center.x, self.dictionaryTableView.center.y + 30);
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
        predicateString = [NSMutableString stringWithFormat: @"tags.name LIKE[c] '%@*'",  self.selectedTag.name];
    else
        predicateString = [NSMutableString stringWithFormat: @"tags.name LIKE[c] '%@*'",  self.selectedTag.name];
    
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

// Back to prev view
-(IBAction) back
{
    [self dismissViewControllerAnimated: YES completion: nil];
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
