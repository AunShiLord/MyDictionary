//
//  ViewControllerSearch.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MBProgressHUD;
@class ViewControllerEditWord;

@interface ViewControllerSearch : UIViewController
{
    NSManagedObjectContext *managedObjectContex;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
