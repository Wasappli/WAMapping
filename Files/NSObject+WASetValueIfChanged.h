//
//  NSObject+WASetValueIfChanged.h
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface NSObject (WASetValueIfChanged)

- (void)wa_setValueIfChanged:(id)value forKey:(NSString *)key;

@end
