//
//  ViewControllerSearch.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerSearch.h"


@interface ViewControllerSearch ()

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation ViewControllerSearch

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Add" style: UIBarButtonItemStylePlain target: self action: @selector(addWordToDatabase)]];
        [self.navigationItem.leftBarButtonItem setEnabled: NO];
        isDataFound = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textField.delegate = self;
    //parsedWord = [parsedWord init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Action on pressing "Go" on keyboard;
- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [textField resignFirstResponder];
    [self getHtmlByWord];
    
    return YES;
}

// Getting an html Data from online dictionary
- (IBAction) getHtmlByWord {
    
    if ( ![self.textField.text isEqual: @""] )
    {
        // link to Yandex Dictionary.
        NSString *url_str = @"https://slovari.yandex.ru/~книги/Толковый словарь Даля/";
        url_str = [[url_str stringByAppendingString: [self.textField.text uppercaseString]] stringByAppendingString: @"/"];
        NSURL *dictionary_url = [NSURL URLWithString:
                             [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

        NSData *dictionaryHtmlData = [NSData dataWithContentsOfURL: dictionary_url];
        
        // is data exists
        if (dictionaryHtmlData)
        {
            [self.navigationItem.leftBarButtonItem setEnabled: YES];
            [self parseHtml: dictionaryHtmlData];
        }
        else
        {
            UIAlertView *hialert = [[UIAlertView alloc]
                                    initWithTitle: @"Ops!" message: @"Word is not found :( \n Sorry!" delegate: nil cancelButtonTitle: @"Okey" otherButtonTitles: nil];
            [hialert show];
            self.textView.attributedText = [[NSAttributedString alloc] initWithString: @""];
            [self.navigationItem.leftBarButtonItem setEnabled: NO];
        }
    }
    
}

// Parsing dictionary html
-(void) parseHtml: (NSData *) htmlData
{
    TFHpple *dictionaryParser = [TFHpple hppleWithHTMLData: htmlData];
    
    NSString *XpathString = @"//div[@class='body article']/p";
    NSArray *dictionaryNodes = [dictionaryParser searchWithXPathQuery: XpathString];
    NSArray *nonTextNodes = [[dictionaryNodes objectAtIndex: 0] children];
    
    NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
    parsedText = [self goDeepAndFindText: nonTextNodes];

    self.textView.attributedText = parsedText;
    
}

// Recursive function that goes deep into the childs nodes tree and return right-attributed text.
-(NSMutableAttributedString *) goDeepAndFindText: (NSArray *) childsNodes
{
    NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
    for (TFHppleElement *i in childsNodes)
    {
        if ([i.tagName isEqual: @"text"])
        {
            
            UIFont *font;
            // setting bold, italic, italic-bold or common font
            if ([i.parent.tagName isEqual: @"strong"])
            {
                if ([i.parent.parent.tagName isEqual: @"em"])
                {
                    font = [UIFont fontWithName: @"Helvetica-BoldOblique" size: [UIFont systemFontSize]];
                }
                else
                {
                    font = [UIFont fontWithName: @"Helvetica-Bold" size: [UIFont systemFontSize]];
                }
            }
            
            else if ([i.parent.tagName isEqual: @"em"])
            {
                if ([i.parent.parent.tagName isEqual: @"strong"])
                {
                    font = [UIFont fontWithName: @"Helvetica-BoldOblique" size: [UIFont systemFontSize]];
                }
                else
                {
                    font = [UIFont fontWithName: @"Helvetica-Oblique" size: [UIFont systemFontSize]];
                }
            }
            
            else
            {
                font = [UIFont fontWithName: @"Helvetica" size: [UIFont systemFontSize]];
            }
            
            // appending string with attributes
            [parsedText appendAttributedString: [[NSMutableAttributedString alloc] initWithString: i.content
                                                                                       attributes: @{NSFontAttributeName : font} ]];
        }
        else
        {
            [parsedText appendAttributedString: [self goDeepAndFindText: i.children]];
        }
    }
        
    return parsedText;
}

// Adding data to database // test method //
- (void) addWordToDatabase
{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: context];
    //NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: [entity name]  inManagedObjectContext: context];
    //[object setValue: self.textField.text forKey: @"name"];
    //[object setValue: self.textView.attributedText forKey: @"definition"];
    /*
    parsedWord = [NSEntityDescription insertNewObjectForEntityForName: @"Word" inManagedObjectContext: context];
    parsedWord.name = self.textField.text;
    parsedWord.definition = self.textView.attributedText;
     */
    
    Word *someWord = [NSEntityDescription insertNewObjectForEntityForName: @"Word" inManagedObjectContext: context];
    someWord.name = self.textField.text;
    someWord.definition = self.textView.attributedText;
    
    //[parsedWord setValue: self.textField.text forKey: @"name"];
    //[parsedWord setValue: self.textView.attributedText forKey: @"definition"];
    
    [request setEntity: entity];
    [request setIncludesPropertyValues: YES];
    NSArray *results = [context executeFetchRequest: request error: nil];
    for (NSManagedObject *obj in results)
    {
        NSString *str = [[NSString alloc] init];
        str = [obj valueForKey: @"name"];
        NSLog(@"I found! %@", str);
    }
    //[context save: nil];
    
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    self.viewControllerEditWord.navigationItem.title = someWord.name;
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
    //[self.navigationController presentViewController: self.viewControllerEditWord animated:YES completion: nil];
    //[self.navigationController pushViewController: NCvcEditWord animated: YES];
    [self presentViewController: NCvcEditWord animated: YES completion: nil];
    
    
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
