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
    // NSURL *url12 = [NSURL URLWithString: @"http://bbs.sjtu.edu.cn/file/bbs/mobile/top100.html"];
    NSURL *url12 = [NSURL URLWithString: [@"https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20150105T101949Z.bc712af51ea9580c.bd4702cc00d35c7a895636ff917b517502a61c5d&lang=en-en&text=" stringByAppendingString: self.textField.text]];
    NSString *res = [NSString stringWithContentsOfURL: url12
                                             encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error: nil];
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
