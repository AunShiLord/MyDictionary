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
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: context];
    //NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: [entity name]  inManagedObjectContext: context];
    //[object setValue: self.textField.text forKey: @"name"];
    //[object setValue: self.textView.attributedText forKey: @"definition"];
    //Word *word = [NSEntityDescription insertNewObjectForEntityForName: @"Word" inManagedObjectContext: context];
    
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    wordsFromDictionary = [context executeFetchRequest: request error: nil];
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
       // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[wordsFromDictionary objectAtIndex: indexPath.row] valueForKey: @"name"];
    //cell.detailTextLabel.text = [[wordsFromDictionary objectAtIndex: indexPath.row] valueForKey: @"definition"];
    
    return cell;
}

// Text Field
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
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
