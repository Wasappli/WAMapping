//
//  NSArray+WAMergeableCollection.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSArray+WAMergeableCollection.h"
#import "WAMappingMacros.h"

@implementation NSArray (WAMergeableCollection)

- (instancetype)wa_collectionMergedWith:(id<WAMergeableCollectionProtocol>)toMerge {
    WAMProtocolClassAssert(toMerge, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toMerge, NSArray);

    return [[[self mutableCopy] wa_collectionMergedWith:toMerge] copy];
}

- (instancetype)wa_collectionMinus:(id<WAMergeableCollectionProtocol>)toRemove {
    WAMProtocolClassAssert(toRemove, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toRemove, NSArray);
    
    return [[[self mutableCopy] wa_collectionMinus:toRemove] copy];
}

@end
