//
//  ViewControllerEditWord.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 05/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@class Word;

@interface ViewControllerEditWord : UIViewController 

@property (strong, nonatomic) Word *selectedWord;
@property (nonatomic)         BOOL deleteWordOnBack;

@end
