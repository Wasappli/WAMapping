//
//  WAEntityMapping.h
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

#import "WABlockMapping.h"

@class WARelationshipMapping;
@class WAPropertyMapping;

/**
 A class which represents the mapping between an NSObject class and a dictionary representation of this class
*/
@interface WAEntityMapping : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Retrieve the mapping for an entity name
 *
 *  @param name The name of the entity
 *
 *  @return the corresponding mapping
 */
+ (instancetype _Nonnull)mappingForEntityName:(NSString *_Nonnull)entityName;

- (instancetype _Nonnull)initWithEntityName:(NSString *_Nonnull)entityName NS_DESIGNATED_INITIALIZER;

/**
 *  Add attributes mappings
 *
 *  @param attributeMappings A dictionary which represents source <-> destination. The key is the source property name, the value is the destination property name (your class file)
 */
- (void)addAttributeMappingsFromDictionary:(NSDictionary *_Nonnull)attributeMappings;

/**
 *  Add custom mappings. For example, if you want to uppercase a value, or use a data transformer.
 *
 *  @param sourceProperty the source property name (ex: `google_place_id`)
 *  @param destinationProperty the destination property name (ex: `googlePlaceID`)
 *  @param mappingBlock the block used to transform the value from JSON to the object
 */
- (void)addMappingFromSourceProperty:(NSString *_Nonnull)sourceProperty toDestinationProperty:(NSString *_Nonnull)destinationProperty withBlock:(_Nullable WAMappingBlock)mappingBlock;

/**
 *  Add custom mappings with a reverse block for turning object into JSON
 *
 *  @param sourceProperty the source property name (ex: `google_place_id`)
 *  @param destinationProperty the destination property name (ex: `googlePlaceID`)
 *  @param mappingBlock the block used to transform the value from JSON to the object
 *  @param reverseMappingBlock the block used to transform the value from the object to JSON
 */
- (void)addMappingFromSourceProperty:(NSString *_Nonnull)sourceProperty toDestinationProperty:(NSString *_Nonnull)destinationProperty withBlock:(_Nullable WAMappingBlock)mappingBlock reverseBlock:(_Nullable WAMappingBlock)reverseMappingBlock;

/**
 *  You can add some relation ship mappings.
 *
 *  @param relationshipMapping The relation ship mapping
 */
- (void)addRelationshipMapping:(WARelationshipMapping *_Nonnull)relationshipMapping;

/**
 *  Identification attribute property name of the destination object
 */
@property (nonatomic, strong) NSString *_Nullable identificationAttribute;
/**
 *  Identification attribute property name of the source object (dictionary)
 */
@property (nonatomic, readonly) NSString *_Nullable inverseIdentificationAttribute;

/**
 *  The entity name. The class name for classic objects and the entity name in CoreData for example.
 */
@property (nonatomic, strong, readonly) NSString *_Nonnull entityName;

/**
 *  A dictionary which represents all the properties used for mapping. The keys are the destination properties name
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, WAPropertyMapping *> *_Nullable attributeMappings;

/**
 *  A dictionary which represents all the properties used for reversed mapping. The keys are the source properties name
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, WAPropertyMapping *> *_Nullable inverseAttributeMappings;

/**
 *  An array representing all the relation ships on an object
 */
@property (nonatomic, strong, readonly) NSArray *_Nullable relationshipMappings;

@end
