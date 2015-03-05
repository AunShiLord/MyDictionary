//
//  ViewControllerDictionary.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
// REVIEW Зачем?
#import "Word.h"
#import "MBProgressHUD.h"
// REVIEW Подключать заголовки в файле реализации, если здесь они не используютсяЮ

@class ViewControllerEditWord;

@interface ViewControllerDictionary : UIViewController <UITableViewDelegate,
                                                        UITableViewDataSource,
                                                        UITextFieldDelegate,
                                                        UIGestureRecognizerDelegate,
                                                        MBProgressHUDDelegate>
    // REVIEW Перенести список реализуемых протоколов в файл реализации.
{
    NSMutableArray  *managedObjectsFromDictionary;
    MBProgressHUD   *messageHud;
    // REVIEW Поменять на @property в файле реализацииЮ
}
// name of entity in CoreData
@property (strong, nonatomic) NSString                  *entityName;
@property (strong, nonatomic) IBOutlet UITextField      *textField;
@property (nonatomic, retain) NSManagedObjectContext    *managedObjectContext;
// REVIEW Почему retain? В чём разница между retain и strong?
@property (strong, nonatomic) IBOutlet UITableView      *dictionaryTableView;
@property (strong, nonatomic) ViewControllerEditWord    *viewControllerEditWord;
// REVIEW Все свойства, что используются лишь этим классом, нужно
// REVIEW переместить в файл реализации.

// REVIEW Почему UIViewController, а внутри UITableView? Почему не UITableViewController?
@end
