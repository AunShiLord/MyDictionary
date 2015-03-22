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
    //tabBarController.tabBar.translucent = NO;
    //[tabBarController.tabBar setTintColor:[UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0]];
    [tabBarController.tabBar setBackgroundColor:[UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0]];
    //tabBarController.tabBar.viewForBaselineLayout.backgroundColor = [UIColor redColor];
    //[tabBarController.tabBar setBackgroundColor:[UIColor redColor]];
   
    [tabBarController.tabBar setBackgroundImage: [UIImage imageNamed: @"tabBarBackground.png"]];
    [tabBarController.tabBar setTintColor: [UIColor whiteColor]];
    
    // first tab viewController. Search in online dictionary
    ViewControllerSearch *viewControllerSearch = [[ViewControllerSearch alloc] init];
    viewControllerSearch.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationControllerSearch = [[UINavigationController alloc]
                                                          initWithRootViewController:viewControllerSearch];
    navigationControllerSearch.tabBarItem = [[UITabBarItem alloc]
                                             initWithTitle:NSLocalizedString(@"Search", @"Tab for search view")
                                             image:[UIImage imageNamed:@"searchIcon"]
                                             selectedImage:[UIImage imageNamed:@"searchIcon"]];
    //[navigationControllerSearch.tabBarController.tabBar setBackgroundColor:[UIColor colorWithRed:110/255.0 green:177/255.0 blue:219/255.0 alpha:1.0]];
    
    // second tab viewController. CoreData database, display words.
    ViewControllerWords *viewControllerWords = [[ViewControllerWords alloc]
                                                initWithNibName:@"ViewControllerDictionary"
                                                bundle:nil];
    viewControllerWords.managedObjectContext = self.managedObjectContext;
    viewControllerWords.entityName = @"Word";
    viewControllerWords.tabBarItem = [[UITabBarItem alloc]
                                      initWithTitle:NSLocalizedString(@"Words", @"Tab for words view")
                                      image:[UIImage imageNamed:@"wordsIcon"]
                                      selectedImage:[UIImage imageNamed:@"wordsIcon"]];
    
    // third tab viewController. CoreData database, display tags.
    ViewControllerTag *viewControllerTag = [[ViewControllerTag alloc]
                                            initWithNibName:@"ViewControllerDictionary"
                                            bundle:nil];
    viewControllerTag.entityName = @"Tag";
    viewControllerTag.managedObjectContext = self.managedObjectContext;
    viewControllerTag.tabBarItem = [[UITabBarItem alloc]
                                    initWithTitle:NSLocalizedString(@"Tags", @"Tab for tags view")
                                    image:[UIImage imageNamed:@"tagsIcon"]
                                    selectedImage:[UIImage imageNamed:@"tagsIcon"]];
    
    [tabBarController setViewControllers:@[navigationControllerSearch, viewControllerWords, viewControllerTag]];
    
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:tabBarController];
    
    return YES;
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

@end
