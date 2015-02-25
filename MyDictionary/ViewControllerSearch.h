//
//  ViewControllerSearch.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 1/17/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TFHpple.h>
#import "MBProgressHUD.h"

@class ViewControllerEditWord;

@interface ViewControllerSearch : UIViewController <UITextFieldDelegate,
                                                    NSURLConnectionDelegate,
                                                    MBProgressHUDDelegate>
{
    NSString      *wordTitle;
    NSMutableData *onlineDictionaryHtmlData;
    MBProgressHUD *urlConnectionHud;
    MBProgressHUD *messageHud;
}
@property (strong,nonatomic) ViewControllerEditWord *viewControllerEditWord;


@end
