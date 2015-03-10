//
//  ViewControllerWordsWithTag.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 11/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerDictionary.h"
@class Tag;

@interface ViewControllerWordsWithTag : ViewControllerDictionary

@property (strong, nonatomic) Tag *selectedTag;

@end
