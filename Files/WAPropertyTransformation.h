//
//  WAPropertyTransformation.h
//  WAMapping
//
//  Created by Marian Paul on 09/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@interface WAPropertyTransformation : NSObject

+ (id _Nullable)propertyValue:(_Nullable id)initialValue fromPropertyName:(NSString *_Nonnull)propertyName forObject:(_Nonnull id)object;
+ (NSString *_Nullable)propertyTypeStringRepresentationFromPropertyName:(NSString *_Nonnull)propertyName forObject:(_Nonnull id)object;
+ (BOOL)isClassACollection:(_Nonnull Class)class;
+ (BOOL)isClassAMutableCollection:(_Nonnull Class)class;
+ (id _Nullable)convertObject:(_Nonnull id)object toClass:(_Nonnull Class)destinationClass;

@end
