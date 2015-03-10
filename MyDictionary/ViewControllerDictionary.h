//
//  ViewControllerDictionary.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
// REVIEW Зачем?
// REVIEW Подключать заголовки в файле реализации, если здесь они не используютсяЮ
// ANSWER Убрал ненужные заголовки в файл реализации

@class ViewControllerEditWord;
@class MBProgressHUD;

@interface ViewControllerDictionary : UIViewController 
    // REVIEW Перенести список реализуемых протоколов в файл реализации.
    // ANSWER Перенес протоколы в файл реализации.

@property (strong, nonatomic) NSMutableArray            *managedObjectsFromDictionary;
@property (strong, nonatomic) MBProgressHUD             *messageHud;
// name of entity in CoreData
@property (strong, nonatomic) NSString                  *entityName;
@property (strong, nonatomic) IBOutlet UITextField      *textField;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
// REVIEW Почему retain? В чём разница между retain и strong?
// ANSWER Как понял почти ни в чем. strong это замена reatain в ARC.
// ANSWER Во всех примерах был ретейн его и использовал. Исправил, чтобы глаза не мозолило.
@property (strong, nonatomic) IBOutlet UITableView      *dictionaryTableView;
@property (strong, nonatomic) ViewControllerEditWord    *viewControllerEditWord;
@property (strong, nonatomic) UINavigationController    *navigationControllerEditWord;
// REVIEW Все свойства, что используются лишь этим классом, нужно
// REVIEW переместить в файл реализации.
// ANSWER От этого класса наследуются три других.
// ANSWER Все эти свойства необходимо оставить.
// ANSWER Другие файлы почистил.

// REVIEW Почему UIViewController, а внутри UITableView? Почему не UITableViewController?
// ANSWER У меня есть еще и UILabel. В ксибе размер UITablewView для UITableViewController менять нельзя,
// ANSWER он занимает вьюшку целиком. В общем, мне просто удобнее было использовать UIViewController.
@end
