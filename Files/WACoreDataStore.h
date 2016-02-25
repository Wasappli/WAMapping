//
//  WACoreDataStore.h
//  WAMapping
//
//  Created by Marian Paul on 01/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

#import "WAStoreProtocol.h"

@class NSManagedObjectContext;

/**
 An implementation of a CoreData store
 */
@interface WACoreDataStore : NSObject <WAStoreProtocol>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Create a new store with a managed object context
 *
 *  @param managedObjectContext the managed object context which will be used to perform the mapping
 *
 *  @return an instance of a CoreData store
 */
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, strong) NSManagedObjectContext *context;

@end
