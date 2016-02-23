//
//  WAMapper.m
//  WAMapping
//
//  Created by Marian Paul on 01/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAMapper.h"
#import "WAMappingMacros.h"
#import "WAPropertyTransformation.h"

#import "WAEntityMapping.h"
#import "WAPropertyMapping.h"
#import "WARelationshipMapping.h"

#import "WAStoreProtocol.h"
#import "WAMergeableCollectionProtocol.h"

#import "NSObject+WASetValueIfChanged.h"

@interface WAMapper ()

@property (nonatomic, strong) id <WAStoreProtocol> store;

@end

@implementation WAMapper

- (instancetype)initWithStore:(id<WAStoreProtocol>)store {
    WAMProtocolClassAssert(store, WAStoreProtocol);
    
    self = [super init];
    if (self) {
        self.store = store;
    }
    
    return self;
}

+ (instancetype)newMapperWithStore:(id<WAStoreProtocol>)store {
    return [[self alloc] initWithStore:store];
}

- (void)mapFromRepresentation:(id)json mapping:(WAEntityMapping *)mapping completion:(WAMapperCompletionBlock)completion {
    WAMParameterAssert(completion);
    WAMAssert(self.store, @"You need to setup a store");
    
    [self.store beginTransaction];

    NSArray *mappedObjects = [self _mapFromRepresentation:json mapping:mapping];
    
    [self.store commitTransaction];
    
    completion(mappedObjects);
}

#pragma mark - Private methods

- (NSArray *)_mapFromRepresentation:(id)json mapping:(WAEntityMapping *)mapping {
    
    NSArray *resolvedArray = nil;
    if ([json isKindOfClass:[NSArray class]] && [[json firstObject] isKindOfClass:[NSDictionary class]]) {
        resolvedArray = json;
    } else if ([json isKindOfClass:[NSDictionary class]]) {
        resolvedArray = @[json];
    } else if (json) {
        // Rebuild a dictionary. This comes from relation ship attributes where you can have "employees": [1, 2, 3]
        if ([json isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[json count]];
            for (id obj in json) {
                [array addObject:@{mapping.inverseIdentificationAttribute: obj}];
            }
            resolvedArray = [array copy];
        } else {
            resolvedArray = @[@{mapping.inverseIdentificationAttribute: json}];
        }
    } else {
        return nil;
    }
    
    // Grab the attributes values
    NSMutableArray *objectsIdentificationAttributes = [NSMutableArray array];
    for (id representation in resolvedArray) {
        id object = nil;
        if ([representation isKindOfClass:[NSDictionary class]] && mapping.inverseAttributeMappings) {
            object = representation[mapping.inverseIdentificationAttribute];
        } else {
            object = representation;
        }
        
        if (object) {
            if ([object isKindOfClass:[NSArray class]]) {
                [objectsIdentificationAttributes addObjectsFromArray:object];
            } else {
                [objectsIdentificationAttributes addObject:object];
            }
        }
    }
    
    // Ask the store to grab the existing objects
    NSArray *existingObjects = nil;
    
    if (mapping.identificationAttribute) {
        existingObjects = [self.store objectsWithAttributes:[objectsIdentificationAttributes copy]
                                                 forMapping:mapping];
    }
    
    // Index the objects
    NSMutableDictionary *indexedObjects = [NSMutableDictionary dictionary];
    for (id obj in existingObjects) {
        id key = [obj valueForKey:mapping.identificationAttribute];
        WAM_OBJ_TO_NIL_IF_NULL(key);
        
        if (key) {
            indexedObjects[key] = obj;
        }
    }
    
    NSMutableArray *objectsMapped = [NSMutableArray new];
    
    // Go through all objects in json
    for (NSDictionary *dic in resolvedArray) {
        // Get the object if existing
        id inverseAttribute = mapping.inverseIdentificationAttribute;
        id sourceIDValue = nil;
        if (inverseAttribute) {
            sourceIDValue = dic[inverseAttribute];
            WAM_OBJ_TO_NIL_IF_NULL(sourceIDValue);
        }
        
        id objectToApplyMappingOn = nil;
        if (sourceIDValue) {
            objectToApplyMappingOn = indexedObjects[sourceIDValue];
        }
        
        if (!objectToApplyMappingOn) {
            objectToApplyMappingOn = [self.store newObjectForMapping:mapping];
        }
        
        NSArray *relationShipObjects = [self _applyMapping:mapping
                                                  onObject:objectToApplyMappingOn
                                        withRepresentation:dic];
        
        [objectsMapped addObject:objectToApplyMappingOn];
        [objectsMapped addObjectsFromArray:relationShipObjects];
    }
    
    
    return [objectsMapped copy];
}

- (NSArray *)_applyMapping:(WAEntityMapping *)mapping onObject:(id)object withRepresentation:(NSDictionary *)representation {
    
    // Map values
    for (NSString *key in [mapping.attributeMappings allKeys]) {
        NSArray *attributes = [key componentsSeparatedByString:@"."];
        id value = representation[[attributes firstObject]];
        if (![value isEqual:[NSNull null]]) {
            for (int i = 1 ; i < [attributes count] ; i ++) {
                value = value[attributes[i]];
                if ([value isEqual:[NSNull null]]) {
                    break;
                }
            }
        }
        
        id finalValue = value;
        if (value && [value isEqual:[NSNull null]]) {
            finalValue = nil;
        }
        
        WAPropertyMapping *propertyMapping = mapping.attributeMappings[key];
        if (finalValue) {
            finalValue = propertyMapping.mappingBlock(finalValue);
        }
        
        if ((!finalValue && [value isEqual:[NSNull null]])
            ||
            finalValue) {
            [object wa_setValueIfChanged:finalValue
                                  forKey:propertyMapping.destinationPropertyName];
        }
    }
    
    NSMutableArray *relationShipObjects = [NSMutableArray array];
    
    // Map relationships
    for (WARelationshipMapping *relationShipMapping in mapping.relationshipMappings) {
        
        NSString *propertyNameToFetch = relationShipMapping.sourceProperty ? : relationShipMapping.sourceIdentificationAttribute;
        
        // Get components
        NSArray *attributes = [propertyNameToFetch componentsSeparatedByString:@"."];
        NSDictionary *value = representation[[attributes firstObject]];
        if (![value isEqual:[NSNull null]]) {
            for (int i = 1 ; i < [attributes count] ; i ++) {
                value = value[attributes[i]];
                if ([value isEqual:[NSNull null]]) {
                    break;
                }
            }
        }
        
        // Handle null
        id finalValue = value;
        if (value && [value isEqual:[NSNull null]]) {
            finalValue = nil;
        }
        
        if (!finalValue && ![value isEqual:[NSNull null]]) {
            continue;
        }
        
        id finalObjects = nil;
        if (finalValue) {
            NSArray *mappedObjects = [self _mapFromRepresentation:finalValue
                                                          mapping:relationShipMapping.mapping];
            
            [relationShipObjects addObjectsFromArray:mappedObjects];
            
            finalObjects = [WAPropertyTransformation propertyValue:mappedObjects
                                                  fromPropertyName:relationShipMapping.destinationProperty
                                                         forObject:object];
        }
        
        switch (relationShipMapping.relationshipPolicy) {
            case WARelationshipPolicyMerge:
            {
                id initialValue = [object valueForKey:relationShipMapping.destinationProperty];
                
                if ([WAPropertyTransformation isClassACollection:[finalObjects class]]
                    ||
                    [WAPropertyTransformation isClassACollection:[initialValue class]]) {
                    if (!initialValue) {
                        // We need to create a new empty collection
                        if ([finalObjects isKindOfClass:[NSArray class]]) {
                            initialValue = @[];
                        } else if ([finalObjects isKindOfClass:[NSSet class]]) {
                            initialValue = [NSSet set];
                        } else if ([finalObjects isKindOfClass:[NSOrderedSet class]]) {
                            initialValue = [NSOrderedSet orderedSet];
                        }
                        
                        // which can be mutable
                        if ([WAPropertyTransformation isClassAMutableCollection:[finalObjects class]]) {
                            initialValue = [initialValue mutableCopy];
                        }
                    }
                    
                    finalObjects = finalObjects ? [initialValue wa_collectionMergedWith:finalObjects] : initialValue;
                }
            }
                break;
            case WARelationshipPolicyAssign:
                // Do nothing
                break;
            case WARelationshipPolicyReplace:
            {
                id initialValue = [object valueForKey:relationShipMapping.destinationProperty];
                
                if ([WAPropertyTransformation isClassACollection:[finalObjects class]]
                    ||
                    [WAPropertyTransformation isClassACollection:[initialValue class]]) {
                    // We care about not removing objects we have on new objects
                    id toRemoves = finalObjects ? [initialValue wa_collectionMinus:finalObjects] : initialValue;
                    for (id toRemove in toRemoves) {
                        [self.store deleteObject:toRemove];
                    }
                } else {
                    if (![initialValue isEqual:finalObjects] && initialValue) {
                        [self.store deleteObject:initialValue];
                    }
                }
            }
                break;
            default:
                break;
        }
        [object wa_setValueIfChanged:finalObjects
                              forKey:relationShipMapping.destinationProperty];
    }
    
    return [relationShipObjects copy];
}

@end
