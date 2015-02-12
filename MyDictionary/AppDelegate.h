//
//  AppDelegate.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class ViewControllerSearch;
@class ViewControllerTag;
@class ViewControllerWords;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Core Data
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) saveContext;
- (NSURL *) applicationsDocumentsDirectory;

@end

