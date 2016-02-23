//
//  NSMutableSet+WAMergeableCollection.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSMutableSet+WAMergeableCollection.h"
#import "WAMappingMacros.h"

@implementation NSMutableSet (WAMergeableCollection)

- (instancetype)wa_collectionMergedWith:(id<WAMergeableCollectionProtocol>)toMerge {
    WAMProtocolClassAssert(toMerge, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toMerge, NSSet);
    
    [self unionSet:(NSSet *)toMerge];
    
    return [self mutableCopy];
}

- (instancetype)wa_collectionMinus:(id<WAMergeableCollectionProtocol>)toRemove {
    WAMProtocolClassAssert(toRemove, WAMergeableCollectionProtocol);
    WAMClassParameterAssert(toRemove, NSSet);
    
    [self minusSet:(NSSet *)toRemove];
    
    return [self mutableCopy];
}

@end
