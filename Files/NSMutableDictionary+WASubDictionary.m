//
//  NSMutableDictionary+WASubDictionary.m
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSMutableDictionary+WASubDictionary.h"

@implementation NSMutableDictionary (WASubDictionary)

- (void)wa_setObject:(id)value byCreatingDictionariesForKeyPath:(NSString *)keyPath {
    NSArray *allKeys = [keyPath componentsSeparatedByString:@"."];
    id lastKey = [allKeys lastObject];
    
    NSMutableDictionary *dictionary = self;

    for (NSUInteger i = 0 ; i < [allKeys count] - 1 ; i ++) {
        id key = allKeys[i];
        NSMutableDictionary *nextDictionary = dictionary[key];
        if (!nextDictionary) {
            nextDictionary = [NSMutableDictionary dictionary];
            dictionary[key] = nextDictionary;
        }
        
        dictionary = nextDictionary;
    }
    
    dictionary[lastKey] = value;
}

@end
