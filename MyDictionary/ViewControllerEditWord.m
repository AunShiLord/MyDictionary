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
        //[self.navigationItem setTitle: @"Word"];
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: self action: @selector(back)]];
        [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Done" style:UIBarButtonItemStylePlain target: self action: @selector(done)]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle: self.selectedWord.name];
    self.textViewWordDefinition.attributedText = self.selectedWord.definition;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) back
{
    //[self.navigationController dismissViewControllerAnimated: YES completion: nil];
    [self dismissViewControllerAnimated: YES completion: nil];
}

-(IBAction) done
{
    self.selectedWord.definition = self.textViewWordDefinition.attributedText;
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
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
