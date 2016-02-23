//
//  NSMutableOrderedSet+WAMeargeableCollection.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSMutableOrderedSet+WAMeargeableCollection.h"
#import "WAMappingMacros.h"

@implementation NSMutableOrderedSet (WAMeargeableCollection)

- (instancetype)wa_collectionMergedWith:(id<WAMergeableCollectionProtocol>)toMerge {
    WAMProtocolClassAssert(toMerge, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toMerge, NSOrderedSet);
    
    [self unionOrderedSet:(NSOrderedSet *)toMerge];
    
    return [self mutableCopy];
}

- (instancetype)wa_collectionMinus:(id<WAMergeableCollectionProtocol>)toRemove {
    WAMProtocolClassAssert(toRemove, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toRemove, NSOrderedSet);
    
    [self minusOrderedSet:(NSOrderedSet *)toRemove];
    
    return [self mutableCopy];
}

@end
