//
//  NSMutableDictionary+WASubDictionary.h
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface NSMutableDictionary (WASubDictionary)

- (void)wa_setObject:(id)value byCreatingDictionariesForKeyPath:(NSString *)keyPath;

@end
