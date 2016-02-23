//
//  WAEntityMapping.m
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAEntityMapping.h"
#import "WAMappingMacros.h"

#import "WAPropertyMapping.h"
#import "WARelationshipMapping.h"

@interface WAEntityMapping ()

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *mAttributeMappings;
@property (nonatomic, strong) NSMutableDictionary *mInverseAttributeMappings;
@property (nonatomic, strong) NSMutableArray *mRelationshipMappings;

@end

@implementation WAEntityMapping

- (instancetype)initWithEntityName:(NSString *)entityName {
    WAMClassParameterAssert(entityName, NSString);
    
    self = [super init];
    
    if (self) {
        self.entityName = entityName;
    }
    return self;
}

+ (instancetype)mappingForEntityName:(NSString *)entityName {
    return [[self alloc] initWithEntityName:entityName];
}

- (void)addAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings {
    for (id sourceProperty in [attributeMappings allKeys]) {
        [self addMappingFromSourceProperty:sourceProperty
                     toDestinationProperty:attributeMappings[sourceProperty]
                                 withBlock:NULL];
    }
}

- (void)addMappingFromSourceProperty:(NSString *)sourceProperty toDestinationProperty:(NSString *)destinationProperty withBlock:(WAMappingBlock)mappingBlock {
    [self addMappingFromSourceProperty:sourceProperty
                 toDestinationProperty:destinationProperty
                             withBlock:mappingBlock
                          reverseBlock:NULL];
}

- (void)addMappingFromSourceProperty:(NSString *)sourceProperty toDestinationProperty:(NSString *)destinationProperty withBlock:(WAMappingBlock)mappingBlock reverseBlock:(WAMappingBlock)reverseMappingBlock {
    WAPropertyMapping *propertyMapping = [WAPropertyMapping propertyMappingWithSourcePropertyName:sourceProperty
                                                                          destinationPropertyName:destinationProperty
                                                                                     mappingBlock:mappingBlock
                                                                              reverseMappingBlock:reverseMappingBlock];
    
    // If we don't have a dic, just assign
    if (!self.mAttributeMappings) {
        self.mAttributeMappings = [NSMutableDictionary dictionary];
    }
    self.mAttributeMappings[sourceProperty] = propertyMapping;
    
    // Update the reverse
    if (!self.mInverseAttributeMappings) {
        self.mInverseAttributeMappings = [NSMutableDictionary dictionary];
    }
    self.mInverseAttributeMappings[destinationProperty] = propertyMapping;
}

- (void)addRelationshipMapping:(WARelationshipMapping *)relationshipMapping {
    WAMClassParameterAssert(relationshipMapping, WARelationshipMapping);
    
    if (!self.mRelationshipMappings) {
        self.mRelationshipMappings = [NSMutableArray array];
    }
    
    [self.mRelationshipMappings addObject:relationshipMapping];
}

#pragma mark - Custom getters

- (NSDictionary *)attributeMappings {
    return [self.mAttributeMappings copy];
}

- (NSDictionary *)inverseAttributeMappings {
    return [self.mInverseAttributeMappings copy];
}

- (NSArray *)relationshipMappings {
    return [self.mRelationshipMappings copy];
}

- (NSString *)inverseIdentificationAttribute {
    if (!self.identificationAttribute) {
        return nil;
    }
    
    return ((WAPropertyMapping *)self.mInverseAttributeMappings[self.identificationAttribute]).sourcePropertyName;
}

@end
