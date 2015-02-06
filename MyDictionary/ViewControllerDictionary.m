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
    
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    [request setSortDescriptors: sortDescriptors];
    wordsFromDictionary = [self.managedObjectContext executeFetchRequest: request error: nil];
    for (NSManagedObject *word in wordsFromDictionary)
    {
        NSString *str = [[NSString alloc] init];
        str = [word valueForKey: @"name"];
        NSLog(@"In dictionary: %@", str);
    }
    
    [self.dictionaryTableView reloadData];
   // [self.dictionaryTableView cellForRowAtIndexPath: [[NSIndexPath alloc] initWithIndex: 0] ];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [wordsFromDictionary count];
}

-(UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[wordsFromDictionary objectAtIndex: indexPath.row] valueForKey: @"name"];
    //cell.detailTextLabel.text = [[wordsFromDictionary objectAtIndex: indexPath.row] valueForKey: @"definition"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog( @"Азазаз, щекотно");
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Word *selectedWord = [NSEntityDescription insertNewObjectForEntityForName: @"Word" inManagedObjectContext:self.managedObjectContext];
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    //self.viewControllerEditWord.navigationItem.title = wordFromOnlineDictionary.name;
    self.viewControllerEditWord.selectedWord = wordsFromDictionary[indexPath.row];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
    //[self.navigationController presentViewController: self.viewControllerEditWord animated:YES completion: nil];
    //[self.navigationController pushViewController: NCvcEditWord animated: YES];
    [self presentViewController: NCvcEditWord animated: YES completion: nil];

    
}

// Text Field
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(string);
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // creating predicate WORKS ONCORRECT!
    NSString *predicateString;
    if (textField.text.length >= 2)
        predicateString = [NSString stringWithFormat: @"name LIKE[c] '%@%@*'",  self.textField.text, string];
    else
        predicateString = [NSString stringWithFormat: @"name LIKE[c] '*'"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    [request setSortDescriptors: sortDescriptors];
    [request setPredicate: predicate];
    wordsFromDictionary = [self.managedObjectContext executeFetchRequest: request error: nil];
    
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
