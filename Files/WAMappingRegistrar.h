//
//  WAMappingRegistrar.h
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAEntityMapping;

/**
 *  A convenient class to register all your mappings and avoid creating twice the same
 */
@interface WAMappingRegistrar : NSObject

/**
 *  Register a mapping
 *
 *  @param mapping the mapping to register
 */
- (void)registerMapping:(WAEntityMapping *)mapping;

/**
 *  Retrieve a registered mapping from entity name
 *
 *  @param entityName the entity name of the mapping we are retrieving
 *
 *  @return an existing entity mapping or nil
 */
- (WAEntityMapping *)mappingForEntityName:(NSString *)entityName;

@end
