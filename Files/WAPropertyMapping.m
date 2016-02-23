//
//  WAPropertyMapping.m
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAPropertyMapping.h"

@interface WAPropertyMapping ()

@property (nonatomic, strong) NSString       *sourcePropertyName;
@property (nonatomic, strong) NSString       *destinationPropertyName;
@property (nonatomic, copy  ) WAMappingBlock mappingBlock;
@property (nonatomic, copy  ) WAMappingBlock reverseMappingBlock;

@end

@implementation WAPropertyMapping

- (instancetype)initWithSourcePropertyName:(NSString *)sourcePropertyName destinationPropertyName:(NSString *)destinationPropertyName mappingBlock:(WAMappingBlock)mappingBlock reverseMappingBlock:(WAMappingBlock)reverseMappingBlock {
    self = [super init];
    
    if (self) {
        self.sourcePropertyName      = sourcePropertyName;
        self.destinationPropertyName = destinationPropertyName;
        self.mappingBlock            = mappingBlock ? :(^(id value) {return value;});
        self.reverseMappingBlock     = reverseMappingBlock ? :(^(id value) {return value;});
    }
    
    return self;
}

+ (instancetype)propertyMappingWithSourcePropertyName:(NSString *)sourcePropertyName destinationPropertyName:(NSString *)destinationPropertyName mappingBlock:(WAMappingBlock)mappingBlock reverseMappingBlock:(WAMappingBlock)reverseMappingBlock {
    return [[self alloc] initWithSourcePropertyName:sourcePropertyName
                            destinationPropertyName:destinationPropertyName
                                       mappingBlock:mappingBlock
                                reverseMappingBlock:reverseMappingBlock];
}

@end
