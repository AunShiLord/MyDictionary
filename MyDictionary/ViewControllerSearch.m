//
//  ViewControllerSearch.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerSearch.h"
#import "ViewControllerEditWord.h"
#import <TFHpple.h>
#import "MBProgressHUD.h"
#import "Word.h"

@interface ViewControllerSearch () <UITextFieldDelegate,
                                    NSURLConnectionDelegate,
                                    MBProgressHUDDelegate>

@property (strong, nonatomic) IBOutlet UITextField  *textField;
@property (strong, nonatomic) IBOutlet UIButton     *searchButton;
@property (strong, nonatomic) IBOutlet UITextView   *textView;


@property (strong, nonatomic) NSString      *wordTitle;
@property (strong, nonatomic) NSMutableData *onlineDictionaryHtmlData;
@property (strong, nonatomic) MBProgressHUD *urlConnectionHud;
@property (strong, nonatomic) MBProgressHUD *messageHud;

@property (strong,nonatomic) ViewControllerEditWord *viewControllerEditWord;
@property (strong,nonatomic) UINavigationController *navigationControllerEditWord;



@end

@implementation ViewControllerSearch

#pragma mark - System methods

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", @"Button ""Add"" name")
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(addWordToDatabase)]];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // init new viewController
    self.viewControllerEditWord = [[ViewControllerEditWord alloc] init];
    self.viewControllerEditWord.hidesBottomBarWhenPushed = YES;
    self.viewControllerEditWord.deleteWordOnBack = YES;
    self.navigationControllerEditWord = [[UINavigationController alloc] initWithRootViewController:self.viewControllerEditWord];
    self.navigationControllerEditWord.navigationBar.translucent = NO;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(dismissKeyboard)];
    [self.navigationController.view addGestureRecognizer:tapGesture];
    
    self.textField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - custom methods

// Getting an html Data from online dictionary
- (IBAction)getHtmlByWord
{
    
    if ( ![self.textField.text isEqual:@""] )
    {
        // link to Yandex Dictionary.
        NSString *url_str = @"https://slovari.yandex.ru/~книги/Толковый словарь Даля/";
        url_str = [[url_str stringByAppendingString:[self.textField.text uppercaseString]]
                   stringByAppendingString:@"/"];
        
        // converting url string to Percent Escapes format
        NSURL *dictionary_url = [NSURL URLWithString:
                             [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:dictionary_url];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (self.urlConnectionHud == nil)
        {
            self.urlConnectionHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.urlConnectionHud.delegate = self;
            self.urlConnectionHud.opacity = 0.5f;
            self.urlConnectionHud.center = self.textField.center;
            self.urlConnectionHud.userInteractionEnabled = NO;
        }

        [connection start];

    }
    
}

// showing message
- (void)showErrorMessage:(NSString *)errorString withError:(NSError *)error
{
    if (self.messageHud == nil)
    {
        self.messageHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
        // Configure for text only and offset down
        self.messageHud.mode = MBProgressHUDModeText;
        self.messageHud.delegate = self;
        self.messageHud.labelText = errorString;
        self.messageHud.yOffset = -20;
        self.messageHud.margin = 10.f;
        self.messageHud.userInteractionEnabled = NO;
    
        [self.messageHud hide:YES afterDelay:2];
    }
    NSLog(@"Error:%@", error.userInfo);
}

// Parsing dictionary html
- (void)parseHtml:(NSData *)htmlData
{
    // creating parser and setting Xpath for it.
    TFHpple *dictionaryParser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *XpathString = @"//div[@class='body article']/p";
    NSArray *dictionaryNodes = [dictionaryParser searchWithXPathQuery:XpathString];
    
    // if dictionaryNodes is empty, then the page is wrong
    if ([dictionaryNodes count] == 0)
    {
        [self showErrorMessage:NSLocalizedString(@"Word not found!", @"Error, word not found") withError:nil];
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:@""];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    else
    {
        // parsing block of data
        NSArray *nonTextNodes = [[dictionaryNodes objectAtIndex:0] children];
    
        NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
        parsedText = [self goDeepAndFindText:nonTextNodes];

        self.textView.attributedText = parsedText;
        // formatting word. First letter in uppercase, other in lowercase.
        NSString *firstLetter = [self.textField.text substringToIndex:1];
        self.wordTitle = [[firstLetter uppercaseString] stringByAppendingString:[[self.textField.text lowercaseString] substringFromIndex:1]];
    }
    
}

// Recursive function that goes deep into the childs nodes tree and return right-attributed text.
- (NSMutableAttributedString *)goDeepAndFindText:(NSArray *)childsNodes
{
    NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
    for (TFHppleElement *i in childsNodes)
    {
        if ([i.tagName isEqual:@"text"])
        {
            
            UIFont *font;
            // setting bold, italic, italic-bold or common font, according to tag and parent tag
            if ([i.parent.tagName isEqual:@"strong"])
            {
                if ([i.parent.parent.tagName isEqual:@"em"])
                    font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:[UIFont systemFontSize]];
                else
                    font = [UIFont fontWithName:@"Helvetica-Bold" size:[UIFont systemFontSize]];
            }
            
            else if ([i.parent.tagName isEqual:@"em"])
            {
                if ([i.parent.parent.tagName isEqual:@"strong"])
                    font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:[UIFont systemFontSize]];
                else
                    font = [UIFont fontWithName:@"Helvetica-Oblique" size:[UIFont systemFontSize]];
            }
            
            else
            {
                font = [UIFont fontWithName:@"Helvetica" size:[UIFont systemFontSize]];
            }
            
            // appending string with attributes
            [parsedText appendAttributedString:[[NSMutableAttributedString alloc]
                                                 initWithString:i.content
                                                 attributes:@{NSFontAttributeName:font} ]];
        }
        else
        {
            [parsedText appendAttributedString:[self goDeepAndFindText:i.children]];
        }
    }
        
    return parsedText;
}

// Adding data to database
- (void)addWordToDatabase
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
    
    // creating fetch request and predicate
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@", self.wordTitle];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    if (!error)
    {
        if (count == 0)
        {
            // adding word to date base
            Word *wordFromOnlineDictionary = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.managedObjectContext];
            wordFromOnlineDictionary.name = self.wordTitle;
            wordFromOnlineDictionary.definition = self.textView.attributedText;
            
            [self.managedObjectContext save:nil];
            
            self.viewControllerEditWord.selectedWord = wordFromOnlineDictionary;
        
            [self presentViewController:self.navigationControllerEditWord animated:YES completion:nil];
        }
        else
            // informing user that the word is already in datebase
            [self showErrorMessage:NSLocalizedString(@"Word is already added!", "Error") withError:nil];
    }
    else
        NSLog(@"%@ \n %@", error, error.userInfo);

}

// Dismiss keyboard on tap
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - textField methods

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Notification text did change to change first letter to uppercase
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    return YES;
}

// Action on pressing "Go" on keyboard;
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self getHtmlByWord];
    
    return YES;
}

// making first letter uppercase
- (void)textFieldDidChange:(NSNotification *)notification
{
    // removing observer from notification (to make sure it won't call twice)
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UITextFieldTextDidChangeNotification object:nil];
    
    if (self.textField.text.length == 1)
        // check if first letter is not uppercase
        if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self.textField.text characterAtIndex:0]])
            // make first letter uppercase
            self.textField.text = [self.textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self.textField.text substringToIndex:1] uppercaseString]];
    
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    self.onlineDictionaryHtmlData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [self.onlineDictionaryHtmlData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self parseHtml:self.onlineDictionaryHtmlData];
    [self.urlConnectionHud hide:YES];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    [self showErrorMessage:NSLocalizedString(@"Something bad happened!", @"Unknow error") withError:error];
    [self.urlConnectionHud hide:YES];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    
    if (hud == self.urlConnectionHud)
    {
        [self.urlConnectionHud removeFromSuperview];
        //[urlConnectionHud release];
        self.urlConnectionHud = nil;
    }
    
    if (hud == self.messageHud)
    {
        [self.messageHud removeFromSuperview];
        self.messageHud = nil;
    }

}

@end
