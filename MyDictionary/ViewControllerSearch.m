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

@end

@implementation ViewControllerSearch

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"TempButton" style: UIBarButtonItemStylePlain target: self action: @selector(Search)]];
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

//- (IBAction)Search:(id)sender {
- (IBAction)Search {
    // link to Yandex API.
    // @"https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20150105T101949Z.bc712af51ea9580c.bd4702cc00d35c7a895636ff917b517502a61c5d&lang=ru-ru&text=" stringByAppendingString: self.textField.text]
    // @"https://slovari.yandex.ru/~книги/Толковый%20словарь%20Даля/БАРДА/"
    // @"https://slovari.yandex.ru/~%D0%BA%D0%BD%D0%B8%D0%B3%D0%B8/%D0%A2%D0%BE%D0%BB%D0%BA%D0%BE%D0%B2%D1%8B%D0%B9%20%D1%81%D0%BB%D0%BE%D0%B2%D0%B0%D1%80%D1%8C%20%D0%94%D0%B0%D0%BB%D1%8F/%D0%91%D0%90%D0%A0%D0%94%D0%90/"
    // @"https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20150105T101949Z.bc712af51ea9580c.bd4702cc00d35c7a895636ff917b517502a61c5d&lang=ru-ru&text=кот"
    
    NSString *url_str = @"https://slovari.yandex.ru/~книги/Толковый словарь Даля/";
    url_str = [[url_str stringByAppendingString: [self.textField.text uppercaseString]] stringByAppendingString: @"/"];
    NSURL *dictionary_url = [NSURL URLWithString: [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSError * error;
    NSString *res = [NSString stringWithContentsOfURL: dictionary_url encoding: NSUTF8StringEncoding error: &error];
    
    NSLog(@"%@", res);

    self.textView.text = res;
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
