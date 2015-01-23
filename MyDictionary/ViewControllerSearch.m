//
//  ViewControllerSearch.m
//  MyDictionary
//
//  Created by robert on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerSearch.h"

@interface ViewControllerSearch ()

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewControllerSearch

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"TempButton" style: UIBarButtonItemStylePlain target: self action: @selector(getHtmlByWord)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Getting an html Data from online dictionary
- (IBAction) getHtmlByWord {
    // link to Yandex API.
    // @"https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20150105T101949Z.bc712af51ea9580c.bd4702cc00d35c7a895636ff917b517502a61c5d&lang=ru-ru&text=" stringByAppendingString: self.textField.text]
    // @"https://slovari.yandex.ru/~книги/Толковый%20словарь%20Даля/БАРДА/"
    // @"https://slovari.yandex.ru/~%D0%BA%D0%BD%D0%B8%D0%B3%D0%B8/%D0%A2%D0%BE%D0%BB%D0%BA%D0%BE%D0%B2%D1%8B%D0%B9%20%D1%81%D0%BB%D0%BE%D0%B2%D0%B0%D1%80%D1%8C%20%D0%94%D0%B0%D0%BB%D1%8F/%D0%91%D0%90%D0%A0%D0%94%D0%90/"
    // @"https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20150105T101949Z.bc712af51ea9580c.bd4702cc00d35c7a895636ff917b517502a61c5d&lang=ru-ru&text=кот"
    
    NSString *url_str = @"https://slovari.yandex.ru/~книги/Толковый словарь Даля/";
    url_str = [[url_str stringByAppendingString: [self.textField.text uppercaseString]] stringByAppendingString: @"/"];
    NSURL *dictionary_url = [NSURL URLWithString:
                             [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

    NSData *dictionaryHtmlData = [NSData dataWithContentsOfURL: dictionary_url];
    if (dictionaryHtmlData && ![self.textField.text  isEqual: @""])
    {
        [self parseHtml: dictionaryHtmlData];
    }
    else
    {
        self.textView.attributedText = [[NSAttributedString alloc] initWithString: @"Error!"];
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

// Recursive unction that goes deep into the childs nodes tree and return right-attributed text. AShi.
-(NSMutableAttributedString *) goDeepAndFindText: (NSArray *) childsNodes
{
    NSMutableAttributedString *parsedText = [[NSMutableAttributedString alloc] init];
    for (TFHppleElement *i in childsNodes)
    {
        if ([i.tagName isEqual: @"text"])
        {
            if ([i.parent.tagName isEqual: @"strong"])
            {
                [parsedText appendAttributedString: [[NSMutableAttributedString alloc] initWithString: i.content
                    attributes: @{NSFontAttributeName : [UIFont boldSystemFontOfSize: [UIFont systemFontSize]]} ]];
            }
            
            else if ([i.parent.tagName isEqual: @"em"])
            {
                [parsedText appendAttributedString: [[NSMutableAttributedString alloc] initWithString: i.content
                    attributes: @{NSFontAttributeName : [UIFont italicSystemFontOfSize: [UIFont systemFontSize]]} ]];
            }
                
            //if ([i.parent.tagName isEqual: @"p"])
            else
            {
                [parsedText appendAttributedString: [[NSMutableAttributedString alloc] initWithString: i.content]];
            }
        }
        else
        {
            [parsedText appendAttributedString: [self goDeepAndFindText: i.children]];
        }
    }
        
    return parsedText;
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
