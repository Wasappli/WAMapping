//
//  WANSCodingStore.m
//  WAMapping
//
//  Created by Marian Paul on 26/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WANSCodingStore.h"
#import "WAEntityMapping.h"
#import "WAMappingMacros.h"

@interface WANSCodingStore ()

@property (nonatomic, strong) NSMutableSet *liveObjects;
@property (nonatomic, strong) NSString *archivePath;

@end

@implementation WANSCodingStore

- (instancetype)initWithArchivePath:(NSString *)archivePath {
    WAMClassParameterAssert(archivePath, NSString);
    
    self = [super init];
    if (self) {
        self->_archivePath = archivePath;
    }
    
    return self;
}

#pragma mark - WAStoreProtocol

- (id)newObjectForMapping:(WAEntityMapping *)mapping {
    Class objectClass = NSClassFromString(mapping.entityName);
    WAMProtocolClassAssert(objectClass, NSCoding);
    
    id object = [[objectClass alloc] init];
    
    [self.liveObjects addObject:object];
    
    return object;
}

- (NSArray *)objectsWithAttributes:(NSArray *)attributes forMapping:(WAEntityMapping *)mapping {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@ && %K IN %@", NSClassFromString(mapping.entityName), mapping.identificationAttribute, attributes];
    
    NSArray *filteredArray = [[self.liveObjects filteredSetUsingPredicate:predicate] allObjects];
    
    return filteredArray;
}

- (void)beginTransaction {
    if ([self.liveObjects count] == 0) {
        // Load from archive
        NSSet *archiveSet = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archivePath];
        if (archiveSet) {
            self.liveObjects = [NSMutableSet setWithSet:archiveSet];
        } else {
            self.liveObjects = [NSMutableSet set];
        }
    }
}

- (void)commitTransaction {
    [NSKeyedArchiver archiveRootObject:[self.liveObjects copy] toFile:self.archivePath];
}

- (void)deleteObject:(id)object {
    [self.liveObjects removeObject:object];
}

@end