//
//  ViewControllerSearch.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerSearch.h"
#import "ViewControllerEditWord.h"


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
        
        // converting url string to Percent Escapes format
        NSURL *dictionary_url = [NSURL URLWithString:
                             [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

        //NSData *dictionaryHtmlData = [NSData dataWithContentsOfURL: dictionary_url];
        
        NSURLRequest *request = [NSURLRequest requestWithURL: dictionary_url];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        urlConnectionHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        urlConnectionHud.delegate = self;
        urlConnectionHud.center = self.textField.center;
        urlConnectionHud.userInteractionEnabled = NO;

        [connection start];
        //[connection release];

    }
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    onlineDictionaryHtmlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [onlineDictionaryHtmlData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self.navigationItem.leftBarButtonItem setEnabled: YES];
    [self parseHtml: onlineDictionaryHtmlData];
    [urlConnectionHud hide: YES];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self showErrorMessage: @"Something bad happened!" withError: error];
    [urlConnectionHud hide: YES];
}

// showing message
-(void)showErrorMessage: (NSString *) errorString withError: (NSError *) error
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    
    // Configure for text only and offset down
    
    hud.mode = MBProgressHUDModeText;
    hud.labelText = errorString;
    //[hud setCenter: CGPointMake (hud.center.x, self.textField.bounds.size.height)];
    hud.yOffset = -10;
    hud.margin = 15.f;
    hud.userInteractionEnabled = NO;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:2];

    self.textView.attributedText = [[NSAttributedString alloc] initWithString: @""];
    [self.navigationItem.leftBarButtonItem setEnabled: NO];
    NSLog(@"Error: %@", error.userInfo);
}

// Parsing dictionary html
-(void) parseHtml: (NSData *) htmlData
{
    // creating parser and setting Xpath for it.
    TFHpple *dictionaryParser = [TFHpple hppleWithHTMLData: htmlData];
    
    NSString *XpathString = @"//div[@class='body article']/p";
    NSArray *dictionaryNodes = [dictionaryParser searchWithXPathQuery: XpathString];
    // if dictionaryNodes if empty, then the page is wrong
    if ([dictionaryNodes count] == 0)
        dispatch_async(dispatch_get_main_queue(), ^{
        [self showErrorMessage: @"Word not found! \n Sorry :(" withError: nil];
        });
    else
    {
        // parsing block of data
        NSArray *nonTextNodes = [[dictionaryNodes objectAtIndex: 0] children];
    
        NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
        parsedText = [self goDeepAndFindText: nonTextNodes];

        self.textView.attributedText = parsedText;
        wordTitle = self.textField.text;
    }
    
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
            // setting bold, italic, italic-bold or common font, according to tag and parent tag
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
    
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Word" inManagedObjectContext: self.managedObjectContext];
    
    // creating fetch request and predicate
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", wordTitle];
    
    [fetchRequest setEntity: entity];
    [fetchRequest setPredicate: predicate];
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error: &error];
    
    if (count == 0)
    {
        // adding word to date base
        Word *wordFromOnlineDictionary = [NSEntityDescription insertNewObjectForEntityForName: @"Word" inManagedObjectContext: self.managedObjectContext];
    
        wordFromOnlineDictionary.name = wordTitle;
        wordFromOnlineDictionary.definition = self.textView.attributedText;
        
        //[context save: nil];
        
        self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
        //self.viewControllerEditWord.navigationItem.title = wordFromOnlineDictionary.name;
        self.viewControllerEditWord.selectedWord = wordFromOnlineDictionary;
        self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
        UINavigationController *NCvcEditWord = [[UINavigationController alloc] initWithRootViewController: self.viewControllerEditWord];
        //[self.navigationController presentViewController: self.viewControllerEditWord animated:YES completion: nil];
        //[self.navigationController pushViewController: NCvcEditWord animated: YES];
        [self presentViewController: NCvcEditWord animated: YES completion: nil];
    }
    else
    {
        // informing user that the word is already in datebase
        NSLog(@"Word %@ is in the datebase!", wordTitle);
    }

}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [urlConnectionHud removeFromSuperview];
    //[urlConnectionHud release];
    urlConnectionHud = nil;
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
