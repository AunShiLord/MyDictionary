//
//  AppDelegate.m
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerSearch.h"
#import "ViewControllerTag.h"
#import "ViewControllerWords.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    // REVIEW Лишний пробел.
    
    // first tab viewController. Search in online dictionary
    ViewControllerSearch *viewControllerSearch = [[ViewControllerSearch alloc] init];
    viewControllerSearch.managedObjectContext = self.managedObjectContext;
    // REVIEW Лишний пробел.
    // REVIEW Необходимо использовать camelCase, т.е. vcs.
    UINavigationController *navigationControllerSearch = [[UINavigationController alloc]
                                                          initWithRootViewController:viewControllerSearch];
    // REVIEW Необходимо использовать camelCase.
    // REVIEW Лишний пробел.
    
    // REVIEW Почему не используется NSLocalizedString?
    // ANSWER Эта строка здесь просто не нужна. Использовал ее для эксперемента )
    [navigationControllerSearch.tabBarItem setTitle:NSLocalizedString(@"Search", @"Tab for search view")];
    
    // second tab viewController. CoreData database, display words.
    ViewControllerWords *viewControllerWords = [[ViewControllerWords alloc]
                                                initWithNibName:@"ViewControllerDictionary"
                                                bundle:nil];
    // REVIEW Лишний пробел. Разбить на строки. camelCase.
    viewControllerWords.managedObjectContext = self.managedObjectContext;
    viewControllerWords.entityName = @"Word";
    // REVIEW Почему не используется NSLocalizedString?
    // ANSWER Здесь это не нужно. Это строка определяет какое Entity использовать
    [viewControllerWords.tabBarItem setTitle:NSLocalizedString(@"Words", @"Tab for words view")];
    
    // third tab viewController. CoreData database, display tags.
    ViewControllerTag *viewControllerTag = [[ViewControllerTag alloc]
                                            initWithNibName:@"ViewControllerDictionary"
                                            bundle:nil];
    // REVIEW Лишний пробел. Разбить на строки. camelCase.
    viewControllerTag.entityName = @"Tag";
    viewControllerTag.managedObjectContext = self.managedObjectContext;
    [viewControllerTag.tabBarItem setTitle:NSLocalizedString(@"Tags", @"Tab for tags view")];
    
    [tabBarController setViewControllers:@[navigationControllerSearch, viewControllerWords, viewControllerTag]];
    
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:tabBarController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate:when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Core Data
-(NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DMDictionaryWord" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationsDocumentsDirectory] URLByAppendingPathComponent:@"MyDictionary.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error])
    {
        NSLog(@"Error acquired %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(NSManagedObjectContext *) managedObjectContext
{
    if(_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSURL *) applicationsDocumentsDirectory
{
    return  [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error] )
        {
            NSLog(@"Error:%@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
