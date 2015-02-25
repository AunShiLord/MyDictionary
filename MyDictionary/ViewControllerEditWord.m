//
//  ViewControllerEditWord.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 05/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerEditWord.h"
#import "ViewControllerSearch.h"

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
        self.deleteWordOnBack = NO;
      
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // initiating gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.navigationController.view addGestureRecognizer: tapGesture];
    
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
    
    self.textViewTags.delegate = self;
    self.textViewTags.text = stringOfTags;
}

// get keyboard size
-(CGRect)keyboardFrame:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    return keyboardFrame;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual: self.textViewTags])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isEqual: self.textViewTags])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    }
    [self.view endEditing:YES];
    return YES;
}

// action on keyboard did show
- (void)keyboardDidShow:(NSNotification *)notification
{
    
    CGRect keyboardFrame = [self keyboardFrame:notification];
    
    [self animatedScrollTo: -keyboardFrame.size.height];
    
}

// action on keyboard did hide
-(void)keyboardDidHide:(NSNotification *)notification
{
    [self animatedScrollTo: 0];
}

// animated scroll by Y
-(void) animatedScrollTo: (CGFloat) y
{
    [UIView beginAnimations:@"registerScroll" context:NULL];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    self.view.transform = CGAffineTransformMakeTranslation(0, y);
    [UIView commitAnimations];
}

// Dismiss keyboard on tap
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Cancel changes and returning to prev view
-(IBAction) back
{
    // check if the word is new added (from ViewControllerSearch)
    if (self.deleteWordOnBack)
        [self.managedObjectContext deleteObject: self.selectedWord];
    
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
        // deleting spaces and \n at the beginning and at the and of each tag
        component = [component stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // check if component is blank string ("")
        if ([component isEqual: @""])
            continue;
        
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

@end
