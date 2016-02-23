//
//  WAPropertyTransformation.m
//  WAMapping
//
//  Created by Marian Paul on 09/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "WAPropertyTransformation.h"
#import "WAMappingMacros.h"

@import ObjectiveC.runtime;

@implementation WAPropertyTransformation

+ (id)propertyValue:(id)initialValue fromPropertyName:(NSString *)propertyName forObject:(id)object {
    WAMClassParameterAssert(propertyName, NSString);
    
    NSString *type = [self propertyTypeStringRepresentationFromPropertyName:propertyName forObject:object];
    id valueToConvert = initialValue;
    
    if (type && object && initialValue) {
        // Try to convert the value to an array
        if ([self isClassACollection:NSClassFromString(type)]) {
            
            NSArray *valueAsArray = nil;
            if (![self isClassACollection:[initialValue class]]) {
                valueAsArray = @[initialValue];
            } else {
                valueAsArray = [self convertObject:initialValue toClass:[NSArray class]];
            }
            valueToConvert = valueAsArray;
        }
    }
    
    return [self convertObject:valueToConvert toClass:NSClassFromString(type)];
}

#pragma mark - Private

// Inspired by EasyMapping
+ (NSString *)propertyTypeStringRepresentationFromPropertyName:(NSString *)propertyName forObject:(id)object
{
    objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
    NSString *propertyType   = nil;
    
    if (property) {
        const char *TypeAttribute = "T";
        char *type = property_copyAttributeValue(property, TypeAttribute);
         propertyType = (type[0] != _C_ID) ? @(type) : ({
            (type[1] == 0) ? @"id" : ({
                // Modern format of a type attribute (e.g. @"NSSet")
                type[strlen(type) - 1] = 0;
                @(type + 2);
            });
        });
        free(type);
    }
    
    return propertyType;
}

+ (BOOL)isClassACollection:(Class)class {
    if ([class isSubclassOfClass:[NSArray class]]
        ||
        [class isSubclassOfClass:[NSSet class]]
        ||
        [class isSubclassOfClass:[NSOrderedSet class]]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isClassAMutableCollection:(Class)class {
    if ([class isSubclassOfClass:[NSMutableArray class]]
        ||
        [class isSubclassOfClass:[NSMutableSet class]]
        ||
        [class isSubclassOfClass:[NSMutableOrderedSet class]]) {
        return YES;
    }
    
    return NO;
}

+ (id)convertObject:(id)object toClass:(Class)destinationClass {
    if ([object isMemberOfClass:[destinationClass class]] || !object) {
        return object;
    } else if ([destinationClass isSubclassOfClass:[NSArray class]]) {
        Class sourceClass = [object class];
        if ([self isClassACollection:sourceClass]) {
            if ([sourceClass isSubclassOfClass:[NSSet class]]) {
                return [(NSSet *)object allObjects];
            } else if ([sourceClass isSubclassOfClass:[NSOrderedSet class]]) {
                return [(NSOrderedSet *)object array];
            }
        }
        if ([destinationClass isSubclassOfClass:[NSMutableArray class]]) {
            return [object mutableCopy];
        } else if ([destinationClass isSubclassOfClass:[NSArray class]]) {
            return object;
        } else {
            return @[object];
        }
    } else if ([destinationClass isSubclassOfClass:[NSSet class]]) {
        NSParameterAssert([object isKindOfClass:[NSArray class]]); // Not supported for other inputs (yet)
        if ([destinationClass isSubclassOfClass:[NSMutableSet class]]) {
            return [NSMutableSet setWithArray:object];
        } else {
            return [NSSet setWithArray:object];
        }
    } else if ([destinationClass isSubclassOfClass:[NSOrderedSet class]]) {
        NSParameterAssert([object isKindOfClass:[NSArray class]]); // Not supported for other inputs (yet)
        if ([destinationClass isSubclassOfClass:[NSMutableOrderedSet class]]) {
            return [NSMutableOrderedSet orderedSetWithArray:object];
        } else {
            return [NSOrderedSet orderedSetWithArray:object];
        }
    } else {
        Class sourceClass = [object class];
        if ([self isClassACollection:sourceClass]) {
            if ([sourceClass isSubclassOfClass:[NSSet class]]) {
                return [(NSSet *)object anyObject];
            } else if ([sourceClass isSubclassOfClass:[NSOrderedSet class]]) {
                return [(NSOrderedSet *)object firstObject];
            } else if ([sourceClass isSubclassOfClass:[NSArray class]]) {
                return [(NSArray *)object firstObject];
            }
        }
    }
    
    return object;
}

@end
