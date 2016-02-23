//
//  NSObject+WASetValueIfChanged.m
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "NSObject+WASetValueIfChanged.h"

@implementation NSObject (WASetValueIfChanged)

- (void)wa_setValueIfChanged:(id)value forKey:(NSString *)key {
    if (![value isEqual:[self valueForKey:key]]) {
        [self setValue:value forKey:key];
    }
}

@end
