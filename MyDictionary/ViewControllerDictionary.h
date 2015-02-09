//
//  ViewControllerDictionary.h
//  MyDictionary
//
//  Created by robert on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ViewControllerEditWord.h"
#import "Word.h"

@interface ViewControllerDictionary : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *wordsFromDictionary;
}

@property (strong,nonatomic) ViewControllerEditWord *viewControllerEditWord;

-(void) handleSwipeLeft: gestureRecognizer;

@end
