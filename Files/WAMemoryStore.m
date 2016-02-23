//
//  WAMemoryStore.m
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAMemoryStore.h"
#import "WAEntityMapping.h"

@interface WAMemoryStore ()

@property (nonatomic, strong) NSMutableSet *liveObjects;

@end

@implementation WAMemoryStore

#pragma mark - WAStoreProtocol

- (id)newObjectForMapping:(WAEntityMapping *)mapping {
    id object = [NSClassFromString(mapping.entityName) new];
    
    [self.liveObjects addObject:object];
    
    return object;
}

- (NSArray *)objectsWithAttributes:(NSArray *)attributes forMapping:(WAEntityMapping *)mapping {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@ && %K IN %@", NSClassFromString(mapping.entityName), mapping.identificationAttribute, attributes];
    
    NSArray *filteredArray = [[self.liveObjects filteredSetUsingPredicate:predicate] allObjects];
    
    return filteredArray;
}

- (void)beginTransaction {
    
}

- (void)commitTransaction {
    
}

- (void)deleteObject:(id)object {
    [self.liveObjects removeObject:object];
}

#pragma mark - Custom getters

- (NSMutableSet *)liveObjects {
    if (!_liveObjects) {
        _liveObjects = [NSMutableSet set];
    }
    
    return _liveObjects;
}

@end
