//
//  WAPropertyTransformation.h
//  WAMapping
//
//  Created by Marian Paul on 09/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface WAPropertyTransformation : NSObject

+ (id)propertyValue:(id)initialValue fromPropertyName:(NSString *)propertyName forObject:(id)object;
+ (NSString *)propertyTypeStringRepresentationFromPropertyName:(NSString *)propertyName forObject:(id)object;
+ (BOOL)isClassACollection:(Class)class;
+ (BOOL)isClassAMutableCollection:(Class)class;
+ (id)convertObject:(id)object toClass:(Class)destinationClass;

@end
