//
//  ViewControllerDictionary.m
//  MyDictionary
//
//  Created by robert on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerDictionary.h"

@interface ViewControllerDictionary ()

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *dictionaryTableView;

@end

@implementation ViewControllerDictionary

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textField.delegate = self;
    self.dictionaryTableView.delegate = self;
    self.dictionaryTableView.dataSource = self;
    
    // initiating Gesture Recognizer
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector(handleSwipeLeft:)];
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer: swipeLeft];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // setting request attributes
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    [request setSortDescriptors: sortDescriptors];
    
    // executing request
    wordsFromDictionary = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest: request error: nil]];
    
    // reloading data
    [self.dictionaryTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [wordsFromDictionary count];
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
    
    cell.textLabel.text = [wordsFromDictionary[indexPath.row] valueForKey: @"name"];
    cell.detailTextLabel.text = [[wordsFromDictionary[indexPath.row] valueForKey: @"definition"] string];
    
    return cell;
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // initialize new view controller
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    
    // setting selected word
    self.viewControllerEditWord.selectedWord = wordsFromDictionary[indexPath.row];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
    [self presentViewController: NCvcEditWord animated: YES completion: nil];
    
}

// Gestures
// handling left swipe gesture
-(void) handleSwipeLeft: (UISwipeGestureRecognizer *) gestureRecognizer
{
    // Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView: self.dictionaryTableView];
    
    // Get corresponding index path within the table view
    NSIndexPath *indexPath = [self.dictionaryTableView indexPathForRowAtPoint: location];
    
    if (indexPath)
    {
        // delete object from CoreData, MutableArray and tableview
        [self.managedObjectContext deleteObject: wordsFromDictionary[indexPath.row]];
        [wordsFromDictionary removeObjectAtIndex: indexPath.row];
        
        [self.dictionaryTableView beginUpdates];
        [self.dictionaryTableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
        [self.dictionaryTableView endUpdates];
        
        //[self.managedObjectContext save: nil];
    }
}

// Text Field
// Reloading data in tableview on typing in textfield
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: self.managedObjectContext];
    
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
    wordsFromDictionary = [NSMutableArray arrayWithArray: [self.managedObjectContext executeFetchRequest: request error: nil]];
    
    [self.dictionaryTableView reloadData];
    
    return YES;
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
