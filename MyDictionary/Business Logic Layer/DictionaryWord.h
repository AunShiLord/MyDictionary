//
//  DictionaryWord.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 26/01/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryTag.h"

@interface DictionaryWord : NSObject

// Returns id of the word
@property (nonatomic, readonly) NSInteger *wordId;

// Returns name of the word
@property (nonatomic) NSString *name;

// Return word's difinition
@property (nonatomic) NSString *difinition;

// Return array of possible word tags (NSMutableArray?)
@property (nonatomic) NSArray *tags;

// Inits with full set of information: name, difinition, tags
- (id) initWithFullInfromation: (NSString *) name difinition: (NSString *) difinition tags: (NSArray *) tags;

// Returns word from database
-(DictionaryWord *) getWordByName: (NSString *) name;

// Returns all words from database
-(NSArray *) getAllWords;

// Returns all gets of the word
-(NSArray *) getTags;

// Inserts word to database
-(void) insertWord;

// Inserts word to datebase with given parameters
-(void) insertWordWithInformation: (NSInteger) wordId name: (NSString *) name difinition: (NSString *) difinition tags: (NSArray *) tags;

// Updates word in database
-(void) updateWord: (NSInteger) wordId;

// Updates with given parameters
-(void) updateWordWithInformation: (NSInteger) wordId name: (NSString *) name difinition: (NSString *) difinition tags: (NSArray *) tags;

// Deletes word from datebase
-(void) deleteWordById: (NSInteger) wordId;

// Adds new tag to the word
-(void) addTagToWord: (DictionaryTag *) tag;

// Checks if word is already in Data Base
-(BOOL) isWordInDatebase;

// Checks if word have this tag
-(BOOL) isWordHaveTag: (DictionaryTag *) tag;


@end
