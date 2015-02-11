//
//  ViewControllerEditWord.m
//  MyDictionary
//
//  Created by robert on 05/02/15.
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
        stringOfTags = [stringOfTags stringByAppendingString: @","];
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
    
    // saveing new tags
    NSMutableString *stringOfTags = [NSMutableString stringWithString: self.textViewTags.text];
    NSArray *components = [stringOfTags componentsSeparatedByString:@","];
    for (NSString *component in components)
    {
        Tag *newTag = [NSEntityDescription insertNewObjectForEntityForName: @"Tag" inManagedObjectContext: self.managedObjectContext];
        //NSManagedObject *newTag = [NSEntityDescription insertNewObjectForEntityForName: @"Tag" inManagedObjectContext: self.managedObjectContext];
        //[newTag setValue: component forKey: @"name"];
        newTag.name = component;
        [self.selectedWord addTagsObject: newTag];
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
