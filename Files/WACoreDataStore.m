//
//  WACoreDataStore.m
//  WAMapping
//
//  Created by Marian Paul on 01/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WACoreDataStore.h"
#import "WAMappingMacros.h"

#import "WAEntityMapping.h"

@import CoreData;

@interface WACoreDataStore ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation WACoreDataStore

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    WAMClassParameterAssert(managedObjectContext, NSManagedObjectContext);
    
    self = [super init];
    
    if (self) {
        self.context = managedObjectContext;
    }
    
    return self;
}

#pragma mark - WAStoreProtocol

- (id)newObjectForMapping:(WAEntityMapping *)mapping {
    return [NSEntityDescription insertNewObjectForEntityForName:mapping.entityName
                                         inManagedObjectContext:self.context];
}

- (NSArray *)objectsWithAttributes:(NSArray *)attributes forMapping:(WAEntityMapping *)mapping {
    // Create the fetch request with IN
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:mapping.entityName
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@", mapping.identificationAttribute, attributes];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest
                                                          error:&error];
    
    return fetchedObjects;
}

- (void)beginTransaction {
    
}

- (void)commitTransaction {
    NSError *error = nil;
    [self.context save:&error];
}

- (void)deleteObject:(id)object {
    [self.context deleteObject:object];
}

@end
