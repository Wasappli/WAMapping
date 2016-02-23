//
//  NSMutableArray+WAMergeableCollection.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSMutableArray+WAMergeableCollection.h"
#import "WAMappingMacros.h"

@implementation NSMutableArray (WAMergeableCollection)

- (instancetype)wa_collectionMergedWith:(id<WAMergeableCollectionProtocol>)toMerge {
    WAMProtocolClassAssert(toMerge, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toMerge, NSArray);
    
    // We use NSMutableSet to avoid having duplicates
    NSSet *fromSet = [NSSet setWithArray:self];
    NSMutableSet *toSet = [NSMutableSet setWithArray:(NSArray *)toMerge];
    
    [toSet minusSet:fromSet];
    
    [self addObjectsFromArray:[toSet allObjects]];
    
    return [self mutableCopy];
}

- (instancetype)wa_collectionMinus:(id<WAMergeableCollectionProtocol>)toRemove {
    WAMProtocolClassAssert(toRemove, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toRemove, NSArray);
    
    [self removeObjectsInArray:(NSArray *)toRemove];
    
    return [self mutableCopy];
}

@end
