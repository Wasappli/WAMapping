//
//  NSOrderedSet+WAMergeableCollection.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSOrderedSet+WAMergeableCollection.h"
#import "WAMappingMacros.h"

@implementation NSOrderedSet (WAMergeableCollection)

- (instancetype)wa_collectionMergedWith:(id<WAMergeableCollectionProtocol>)toMerge {
    WAMProtocolClassAssert(toMerge, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toMerge, NSOrderedSet);
    
    return [[[self mutableCopy] wa_collectionMergedWith:toMerge] copy];
}

- (instancetype)wa_collectionMinus:(id<WAMergeableCollectionProtocol>)toRemove {
    WAMProtocolClassAssert(toRemove, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toRemove, NSOrderedSet);
    
    return [[[self mutableCopy] wa_collectionMinus:toRemove] copy];
}

@end
