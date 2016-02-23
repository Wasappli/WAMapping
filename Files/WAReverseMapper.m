//
//  WAReverseMapper.m
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAReverseMapper.h"
#import "WAEntityMapping.h"
#import "WAPropertyMapping.h"
#import "WARelationshipMapping.h"

#import "WAMappingMacros.h"
#import "WAPropertyTransformation.h"

#import "NSMutableDictionary+WASubDictionary.h"

@implementation WAReverseMapper

- (NSArray *)reverseMapObjects:(NSArray *)objects fromMapping:(WAEntityMapping *)mapping shouldMapRelationship:(WAReverseMapperShouldMapRelationshipBlock)shouldMapRelationshipBlock {
    WAMParameterAssert(objects);
    
    NSArray *resolvedArray = nil;
    if ([objects isKindOfClass:[NSArray class]]) {
        resolvedArray = objects;
    } else if (objects) {
        resolvedArray = @[objects];
    } else {
        return nil;
    }
    
    if ([objects count] == 0) {
        return nil;
    }
    
    NSMutableArray *allObjectsAsDictionaries = [NSMutableArray array];
    // We use this dictionary to avoid infinite loops
    NSMutableDictionary *alreadyMappedObjects = [NSMutableDictionary dictionary];
    
    for (id obj in objects) {
        NSDictionary *objectAsDictionary = [self _reverseMapObject:obj
                                                       withMapping:mapping
                                             shouldMapRelationship:shouldMapRelationshipBlock
                                              alreadyMappedObjects:&alreadyMappedObjects];
        if (objectAsDictionary) {
            [allObjectsAsDictionaries addObject:objectAsDictionary];
        }
    }
    
    return [allObjectsAsDictionaries copy];
}

#pragma mark - Private

- (NSString *)_uniqueKeyForObject:(id)object mapping:(WAEntityMapping *)mapping {
    id identificationAttribute = [object valueForKey:mapping.identificationAttribute];
    if (!identificationAttribute) {
        identificationAttribute = [NSString stringWithFormat:@"%p", object];
    }
    
    return [NSString stringWithFormat:@"%@%@", mapping.entityName, identificationAttribute];
}

- (NSDictionary *)_reverseMapObject:(id)object withMapping:(WAEntityMapping *)mapping shouldMapRelationship:(WAReverseMapperShouldMapRelationshipBlock)shouldMapRelationshipBlock alreadyMappedObjects:(NSMutableDictionary**)alreadyMappedObjects {
    
    // Get the unique key for the object
    NSString *uniqueKey = [self _uniqueKeyForObject:object
                                            mapping:mapping];
    
    if (!uniqueKey) {
        // We have not been able to identify the object
        return nil;
    }
    
    // Will create a dictionary
    NSMutableDictionary *objectAsDictionary = [NSMutableDictionary dictionary];
    
    // Assign it to the already mapped objects
    [*alreadyMappedObjects setObject:objectAsDictionary forKey:uniqueKey];
    
    // Iterate through all values
    NSDictionary *reverseMapping = mapping.inverseAttributeMappings;
    
    for (NSString *key in [reverseMapping allKeys]) {
        WAPropertyMapping *propertyMapping = reverseMapping[key];
        
        id value = [object valueForKeyPath:key];
        value = propertyMapping.reverseMappingBlock(value);
        
        [objectAsDictionary wa_setObject:value ?: [NSNull null] byCreatingDictionariesForKeyPath:propertyMapping.sourcePropertyName];
    }
    
    // Map the relation ships
    for (WARelationshipMapping *relationship in mapping.relationshipMappings) {
        NSString *relationshipSourceKeyPath = relationship.sourceProperty ?: relationship.sourceIdentificationAttribute;

        // Continue if we have no reason to map the relationship
        BOOL shouldMapRelationship = shouldMapRelationshipBlock ? shouldMapRelationshipBlock(relationshipSourceKeyPath) : YES;
        if (!shouldMapRelationship) {
            continue;
        }
        
        // Get the objects as an array
        NSArray *objectsOnRelationship = [object valueForKeyPath:relationship.destinationProperty];
        if (!objectsOnRelationship) {
            [objectAsDictionary wa_setObject:[NSNull null] byCreatingDictionariesForKeyPath:relationshipSourceKeyPath];
            continue;
        }
        
        BOOL isToManyRelationShip = [WAPropertyTransformation isClassACollection:[objectsOnRelationship class]];
        if (!isToManyRelationShip) {
            objectsOnRelationship = @[objectsOnRelationship];
        } else {
            objectsOnRelationship = [WAPropertyTransformation convertObject:objectsOnRelationship toClass:[NSArray class]];
        }
        
        // Iterate to reverse map them
        NSMutableArray *objectsOnRelationShipAsDictionaries = [NSMutableArray arrayWithCapacity:objectsOnRelationship.count];
        for (id object in objectsOnRelationship) {
            // Let's see if we already reversed map it
            NSDictionary *existingDictionary = [*alreadyMappedObjects objectForKey:[self _uniqueKeyForObject:object mapping:relationship.mapping]];
            NSDictionary *rObjectAsDictionary = nil;
            
            if (!existingDictionary) {
                rObjectAsDictionary = [self _reverseMapObject:object
                                                  withMapping:relationship.mapping
                                        shouldMapRelationship:shouldMapRelationshipBlock
                                         alreadyMappedObjects:alreadyMappedObjects];
            } else {
                // We are in the case that we already reversed mapped an object. To avoid infinite json due to relationships like Enterprise->employees Employee->Enterprise, we have two options:
                // Option 1: we have a value for identification attribute. The object will only contain this key value
                id identificationAttribute = existingDictionary[relationship.mapping.inverseIdentificationAttribute];
                if (identificationAttribute && ![identificationAttribute isEqual:[NSNull null]]) {
                    rObjectAsDictionary = @{relationship.mapping.inverseIdentificationAttribute: existingDictionary[relationship.mapping.inverseIdentificationAttribute]};
                }
                // Option 2: we have no id: remove all relation ships
                else {
                    rObjectAsDictionary = [self _removeRelationshipsValues:existingDictionary
                                                               withMapping:relationship.mapping];
                }
            }
            
            if (rObjectAsDictionary) {
                [objectsOnRelationShipAsDictionaries addObject:rObjectAsDictionary];
            }
        }
        
        if (isToManyRelationShip) {
            [objectAsDictionary wa_setObject:[objectsOnRelationShipAsDictionaries copy] byCreatingDictionariesForKeyPath:relationshipSourceKeyPath];
        } else {
            id relationshipObject = [objectsOnRelationShipAsDictionaries firstObject];
            if (relationshipObject) {
                [objectAsDictionary wa_setObject:relationshipObject byCreatingDictionariesForKeyPath:relationshipSourceKeyPath];
            }
        }
    }
    
    return [objectAsDictionary copy];
}

- (NSDictionary *)_removeRelationshipsValues:(NSDictionary *)originalRepresentation withMapping:(WAEntityMapping *)mapping {
    NSMutableDictionary *finalRepresentation = [originalRepresentation mutableCopy];

    for (WARelationshipMapping *relationship in mapping.relationshipMappings) {
        NSString *relationshipSourceKeyPath = relationship.sourceProperty ?: relationship.sourceIdentificationAttribute;

        id value = originalRepresentation[relationshipSourceKeyPath];
        if (!value || [value isEqual:[NSNull null]]) {
            continue;
        }
        
        [finalRepresentation removeObjectForKey:relationshipSourceKeyPath];
    }
    
    return [finalRepresentation copy];
}

@end
