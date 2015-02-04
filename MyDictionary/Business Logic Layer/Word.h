//
//  Word.h
//  MyDictionary
//
//  Created by robert on 04/02/15.
//  Copyright (c) 2015 ashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Word : NSManagedObject

@property (nonatomic, retain) id definition;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
