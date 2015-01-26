//
//  DictionaryTag.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 26/01/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryTag : NSObject

// Returns id of the tag
@property (atomic, readonly) NSInteger id;

// Returns name of the tag
@property (atomic) NSString *name;

// init with name
-(id) initWithName: (NSString *) name;

// Returns tag
-(DictionaryTag *) getTag;

// Updates current tag
-(void) updateTag;

// Updates tag with new name
-(void) updateTagWithName: (NSString *) name;

// Inserts tag to datebase
-(void) insertTag;

// Inserts tag with new name
-(void) insertTagWithName: (NSString *) name;

// Deletes tag from datebase
-(void) deleteTagById: (NSInteger *) tagId;
                            
@end
