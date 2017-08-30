//
//  WAStoreProtocol.h
//  WAMapping
//
//  Created by Marian Paul on 29/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAEntityMapping;

/**
 *  A protocol which describes a store used for mapping. Two implementations are provided: one using CoreData and an other keeping objects only in memory.
 */
@protocol WAStoreProtocol <NSObject>

/**
 *  Asks to create a new object using a mapping
 *
 *  @param mapping the mapping used to retrieve the object class name
 *
 *  @return a new object from the store
 */
- (_Nullable id)newObjectForMapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  Asks to delete an object from the store
 *
 *  @param object the object to delete
 */
- (void)deleteObject:(_Nonnull id)object;

/**
 *  Asks to fetch existing objects from attributes values (from `destinationSourcePath` on `WAEntityMapping`)
 *
 *  @param attributes an array of attributes values
 *  @param mapping    the mapping for the objects we are fetching
 *
 *  @return an array of existing objects in the store
 */
- (NSArray *_Nullable)objectsWithAttributes:(NSArray *_Nonnull)attributes forMapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  Begin a transaction. Usually used to initialize or block a context
 */
- (void)beginTransaction;

/**
 *  Commit a transaction. Called on mapping end. Usually used to save the context
 */
- (void)commitTransaction;

@end
