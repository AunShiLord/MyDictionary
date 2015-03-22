//
//  ViewControllerTag.m
//  MyDictionary
//
//  Created by Vladimir Kuzmim on 09/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerTag.h"
#import "ViewControllerWordsWithTag.h"
#import "AppDelegate.h"

@interface ViewControllerTag ()

@property (strong, nonatomic) ViewControllerWordsWithTag   *viewControllerWordsWithTag;
@property (strong, nonatomic) UINavigationController       *navigationControllerWordsWithTag;

@end

@implementation ViewControllerTag

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.entityName = @"Tag";
    self.textField.placeholder = NSLocalizedString(@"Dictionary tag placeholder", nil);
    
    self.viewControllerWordsWithTag = [[ViewControllerWordsWithTag alloc]
                                       initWithNibName:@"ViewControllerDictionary"
                                                bundle:nil];
    self.viewControllerWordsWithTag.managedObjectContext = self.managedObjectContext;
    self.viewControllerWordsWithTag.hidesBottomBarWhenPushed = YES;
    self.navigationControllerWordsWithTag = [[UINavigationController alloc]
                                             initWithRootViewController:self.viewControllerWordsWithTag];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    
    // creating sort descriptor
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    
    // creating predicate
    NSMutableString *predicateString = [NSMutableString stringWithString:self.textField.text];
    
    // if length of string in textfiled is more than 2, then Core Data will search words with format "_wordPart_*", else all words in database
    if (predicateString.length > 2)
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '%@*'",  self.textField.text];
    else
        predicateString = [NSMutableString stringWithFormat:@"name LIKE[c] '*'"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    // setting request attributes
    [request setEntity:entity];
    [request setIncludesPropertyValues:YES];
    [request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    
    // executing request
    self.managedObjectsFromDictionary = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:nil]];
    
    // reloading data
    [self.dictionaryTableView reloadData];
}

// Action performed after tapping on the cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.viewControllerWordsWithTag.selectedTag = self.managedObjectsFromDictionary[indexPath.row];
    [self presentViewController:self.navigationControllerWordsWithTag animated:YES completion:nil];
}


@end
