//
//  WARelationshipMapping.m
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WARelationshipMapping.h"
#import "WAMappingMacros.h"

#import "WAEntityMapping.h"

@interface WARelationshipMapping ()

@property (nonatomic, strong) NSString        *sourceProperty;
@property (nonatomic, strong) NSString        *sourceIdentificationAttribute;
@property (nonatomic, strong) NSString        *destinationProperty;
@property (nonatomic, strong) WAEntityMapping *mapping;

@end

@implementation WARelationshipMapping

- (instancetype)initWithSourceProperty:(NSString *)sourceProperty destinationProperty:(NSString *)destinationProperty mapping:(WAEntityMapping *)mapping {
    WAMClassParameterAssert(sourceProperty, NSString);
    WAMClassParameterAssert(destinationProperty, NSString);
    WAMClassParameterAssert(mapping, WAEntityMapping);
    
    self = [super init];
    
    if (self) {
        self.sourceProperty      = sourceProperty;
        self.destinationProperty = destinationProperty;
        self.mapping             = mapping;
    }
    
    return self;
}

+ (instancetype)relationshipMappingFromSourceProperty:(NSString *)sourceProperty toDestinationProperty:(NSString *)destinationProperty withMapping:(WAEntityMapping *)mapping {
    return [[self alloc] initWithSourceProperty:sourceProperty
                            destinationProperty:destinationProperty
                                        mapping:mapping];
}

- (instancetype)initWithSourceIdentificationAttribute:(NSString *)sourceIdentificationAttribute destinationProperty:(NSString *)destinationProperty mapping:(WAEntityMapping *)mapping {
    WAMClassParameterAssert(sourceIdentificationAttribute, NSString);
    WAMClassParameterAssert(destinationProperty, NSString);
    WAMClassParameterAssert(mapping, WAEntityMapping);
    
    self = [super init];
    
    if (self) {
        self.sourceIdentificationAttribute = sourceIdentificationAttribute;
        self.destinationProperty           = destinationProperty;
        self.mapping                       = mapping;
    }
    
    return self;
}

+ (instancetype)relationshipMappingFromSourceIdentificationAttribute:(NSString *)sourceIdentificationAttribute toDestinationProperty:(NSString *)destinationProperty withMapping:(WAEntityMapping *)mapping {
    return [[self alloc] initWithSourceIdentificationAttribute:sourceIdentificationAttribute
                                           destinationProperty:destinationProperty
                                                       mapping:mapping];
}

@end
