//
//  ObjectWithCollections.h
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectWithCollections : NSObject

@property (nonatomic, strong) NSArray             *arrayProperty;
@property (nonatomic, strong) NSMutableArray      *mArrayProperty;
@property (nonatomic, strong) NSSet               *setProperty;
@property (nonatomic, strong) NSMutableSet        *mSetProperty;
@property (nonatomic, strong) NSOrderedSet        *orderedSetProperty;
@property (nonatomic, strong) NSMutableOrderedSet *mOrderedSetProperty;
@property (nonatomic, strong) id                  nonCollectionProperty;

@end
