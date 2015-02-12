//
//  ViewControllerWordsWithTag.h
//  MyDictionary
//
//  Created by robert on 11/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import "ViewControllerDictionary.h"
#import "Tag.h"

@interface ViewControllerWordsWithTag : ViewControllerDictionary

@property (strong, nonatomic) Tag *selectedTag;

@end
