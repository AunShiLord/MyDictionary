//
//  ViewControllerTag.m
//  MyDictionary
//
//  Created by robert on 09/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerTag.h"

@interface ViewControllerTag ()

@end

@implementation ViewControllerTag

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.entityName = @"Tag";
    self.textField.placeholder = @"Type a tag...";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Action performed after tapping on the cell
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewControllerDictionary *viewControllerWordsWithTag = [[ViewControllerDictionary alloc] init];
    viewControllerWordsWithTag.entityName = @"Word";
    UINavigationController *navigationControllerWordsWithTag = [[UINavigationController alloc] initWithRootViewController: viewControllerWordsWithTag];
    [self presentViewController: navigationControllerWordsWithTag animated: YES completion: nil];
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
