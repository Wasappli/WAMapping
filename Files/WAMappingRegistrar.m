//
//  WAMappingRegistrar.m
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAMappingRegistrar.h"
#import "WAMappingMacros.h"

#import "WAEntityMapping.h"

@interface WAMappingRegistrar ()

@property (nonatomic, strong) NSMutableDictionary *indexedMappings;

@end

@implementation WAMappingRegistrar

- (instancetype)init {
    self = [super init];
    if (self) {
        self.indexedMappings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerMapping:(WAEntityMapping *)mapping {
    WAMClassParameterAssert(mapping, WAEntityMapping);
    
    self.indexedMappings[mapping.entityName] = mapping;
}

- (WAEntityMapping *)mappingForEntityName:(NSString *)entityName {
    WAMClassParameterAssert(entityName, NSString);
    
    return self.indexedMappings[entityName];
}

@end
