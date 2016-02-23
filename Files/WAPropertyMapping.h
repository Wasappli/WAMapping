//
//  WAPropertyMapping.h
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WABlockMapping.h"

/**
 This class represents a property mapping between a source (dictionary) and a destination (object) property name
 */
@interface WAPropertyMapping : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Create a property mapping
 *
 *  @param sourcePropertyName      the property name in a dictionary. Usually from the server side if applicable
 *  @param destinationPropertyName the property name on the object
 *  @param mappingBlock            an optional block which will be called each time the property is transformed. You usually return a value for a transformer like converting a date.
 *  @param reverseMappingBlock     an optional block which usually reverse the behavior from mappingBlock. Used with reverse mapper
 *
 *  @return return a property mapping instance
 */
- (instancetype)initWithSourcePropertyName:(NSString *)sourcePropertyName destinationPropertyName:(NSString *)destinationPropertyName mappingBlock:(WAMappingBlock)mappingBlock reverseMappingBlock:(WAMappingBlock)reverseMappingBlock;

/**
 *  @see `initWithSourcePropertyName: destinationPropertyName: mappingBlock: reverseMappingBlock:`
 */
+ (instancetype)propertyMappingWithSourcePropertyName:(NSString *)sourcePropertyName destinationPropertyName:(NSString *)destinationPropertyName mappingBlock:(WAMappingBlock)mappingBlock reverseMappingBlock:(WAMappingBlock)reverseMappingBlock;

@property (nonatomic, strong, readonly) NSString       *sourcePropertyName;
@property (nonatomic, strong, readonly) NSString       *destinationPropertyName;
@property (nonatomic, copy, readonly  ) WAMappingBlock mappingBlock;
@property (nonatomic, copy, readonly  ) WAMappingBlock reverseMappingBlock;

@end
