//
//  ViewControllerDictionary.h
//  MyDictionary
//
//  Created by robert on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Word.h"

@class ViewControllerEditWord;

@interface ViewControllerDictionary : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *managedObjectsFromDictionary;
}
// name of entity in CoreData
@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *dictionaryTableView;
@property (strong, nonatomic) ViewControllerEditWord *viewControllerEditWord;


-(void) handleSwipeLeft: gestureRecognizer;

@end
