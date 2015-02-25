//
//  ViewControllerWordsWithTag.m
//  MyDictionary
//
//  Created by robert on 11/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerWordsWithTag.h"

@interface ViewControllerWordsWithTag ()

@end

@implementation ViewControllerWordsWithTag

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Left button on navigation controller
        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: self action: @selector(back)]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.entityName = @"Word";
    self.textField.placeholder = @"Type a word...";
    
    NSLog(@"%@", self.selectedTag.name);
    // changing position of textfield and tableview
    [self.navigationItem setTitle: self.selectedTag.name];
    self.textField.center = CGPointMake(self.textField.center.x, self.textField.center.y + 30);
    self.dictionaryTableView.center = CGPointMake(self.dictionaryTableView.center.x, self.dictionaryTableView.center.y + 30);
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.navigationItem.title = self.selectedTag.name;
    
    managedObjectsFromDictionary = [NSMutableArray arrayWithArray: [self.selectedTag.words allObjects]];
    
    // reloading data
    [self.dictionaryTableView reloadData];
}

// Back to prev view
-(IBAction) back
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

@end
