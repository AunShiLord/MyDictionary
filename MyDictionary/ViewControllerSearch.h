//
//  ViewControllerSearch.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TFHpple.h>
#import "AppDelegate.h"
#import "Word.h"
#import "ViewControllerEditWord.h"

@interface ViewControllerSearch : UIViewController <UITextFieldDelegate>
{
    BOOL isDataFound;
    NSString *wordTitle;
}
@property (strong,nonatomic) ViewControllerEditWord *viewControllerEditWord;


@end
