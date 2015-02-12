//
//  Tag.h
//  MyDictionary
//
//  Created by Vladimir Kuzmin on 04/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Word;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *words;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addWordsObject:(Word *)value;
- (void)removeWordsObject:(Word *)value;
- (void)addWords:(NSSet *)values;
- (void)removeWords:(NSSet *)values;

@end
