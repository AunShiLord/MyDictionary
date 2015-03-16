//
//  ViewControllerDictionary.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewControllerEditWord;
@class MBProgressHUD;

@interface ViewControllerDictionary : UIViewController

@property (strong, nonatomic) NSMutableArray            *managedObjectsFromDictionary;
@property (strong, nonatomic) MBProgressHUD             *messageHud;
// name of entity in CoreData
@property (strong, nonatomic) NSString                  *entityName;
@property (strong, nonatomic) IBOutlet UITextField      *textField;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView      *dictionaryTableView;
@property (strong, nonatomic) ViewControllerEditWord    *viewControllerEditWord;
@property (strong, nonatomic) UINavigationController    *navigationControllerEditWord;

@end
