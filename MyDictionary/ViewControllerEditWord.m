//
//  ViewControllerEditWord.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 05/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerEditWord.h"

@interface ViewControllerEditWord ()
@property (strong, nonatomic) IBOutlet UITextView *textViewWordDefinition;
@property (strong, nonatomic) IBOutlet UITextView *textViewTags;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation ViewControllerEditWord

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    
    if (self)
    {
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: self action: @selector(back)]];
        [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Done" style:UIBarButtonItemStylePlain target: self action: @selector(done)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // setting word name and definition
    [self.navigationItem setTitle: self.selectedWord.name];
    self.textViewWordDefinition.attributedText = self.selectedWord.definition;
    
    // setting list of tags
    NSSet *tags = [self.selectedWord tags];
    NSString *stringOfTags = @"";
    for (Tag *tag in tags)
    {
        stringOfTags = [stringOfTags stringByAppendingString: tag.name];
        stringOfTags = [stringOfTags stringByAppendingString: @", "];
    }
    self.textViewTags.text = stringOfTags;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Cancel changes and returning to prev view
-(IBAction) back
{
    //[self.navigationController dismissViewControllerAnimated: YES completion: nil];
    [self dismissViewControllerAnimated: YES completion: nil];
}

// Save changes and returning to prev view
-(IBAction) done
{
    // saving word definition
    self.selectedWord.definition = self.textViewWordDefinition.attributedText;
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    
    // deleting all tags
    [self.selectedWord removeTags: self.selectedWord.tags];
    
    // setting entity
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Tag" inManagedObjectContext: self.managedObjectContext];
    
    // parsing string with tags
    NSMutableString *stringOfTags = [NSMutableString stringWithString: self.textViewTags.text];
    NSArray *components = [stringOfTags componentsSeparatedByString:@","];
    
    for (NSString __strong *component in components)
    {
        // deleting spaces and \n at the brgining and at the and of each tag
        component = [component stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // check if this tag exists
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", component];
        
        [fetchRequest setEntity: entity];
        [fetchRequest setPredicate: predicate];
        
        NSError *error = nil;
        NSArray *tagsWithPredicate = [self.managedObjectContext executeFetchRequest: fetchRequest error: &error];
        if ([tagsWithPredicate count] == 0)
        {
            Tag *newTag = [NSEntityDescription insertNewObjectForEntityForName: @"Tag" inManagedObjectContext: self.managedObjectContext];
            newTag.name = component;
            [self.selectedWord addTagsObject: newTag];
        }
        else
        {
            // check if current word is aready have this tag
            NSSet *wordsTags = self.selectedWord.tags;
            // creating predicate
            NSPredicate *wordPredicate = [NSPredicate predicateWithFormat: @"SELF.name LIKE[c] %@", component];
            wordsTags = [wordsTags filteredSetUsingPredicate: wordPredicate];
            if ([wordsTags count] == 0)
            {
                [self.selectedWord addTagsObject: tagsWithPredicate[0]];
            }
        }
    }
    
    [self.managedObjectContext save: nil];
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
