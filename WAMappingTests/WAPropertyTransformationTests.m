//
//  WAPropertyTransformationTests.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Kiwi.h"
#import "ObjectWithCollections.h"

#import "WAPropertyTransformation.h"

SPEC_BEGIN(WAPropertyTransformationTests)

describe(@"WAPropertyTransformationTests", ^{
    NSArray *initialArray = @[@1, @2, @3, @4];
    id singleValue        = @1;
    NSSet *initialSet     = [[NSSet alloc] initWithArray:initialArray];
    
    ObjectWithCollections *object = [ObjectWithCollections new];
    
    context(@"To array", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"arrayProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSArray class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"arrayProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSArray class]];
            [[finalValue should] haveCountOf:1];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialSet fromPropertyName:@"arrayProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSArray class]];
            [[finalValue should] haveCountOf:4];
        });
    });
    
    context(@"To mutable array", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"mArrayProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableArray class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"mArrayProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableArray class]];
            [[finalValue should] haveCountOf:1];
        });
    });

    context(@"To set", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"setProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSSet class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"setProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSSet class]];
            [[finalValue should] haveCountOf:1];
        });
    });
    
    context(@"To mutable set", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"mSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableSet class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"mSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableSet class]];
            [[finalValue should] haveCountOf:1];
        });
    });
    
    context(@"To ordered set", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"orderedSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSOrderedSet class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"orderedSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSOrderedSet class]];
            [[finalValue should] haveCountOf:1];
        });
    });
    
    context(@"To mutable ordered set", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"mOrderedSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableOrderedSet class]];
            [[finalValue should] haveCountOf:4];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"mOrderedSetProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSMutableOrderedSet class]];
            [[finalValue should] haveCountOf:1];
        });
    });
    
    context(@"To non collection property", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialArray fromPropertyName:@"nonCollectionProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSNumber class]];
            [[finalValue should] equal:@1];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:singleValue fromPropertyName:@"nonCollectionProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSNumber class]];
            [[finalValue should] equal:@1];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:initialSet fromPropertyName:@"nonCollectionProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSNumber class]];
        });
    });
    
    context(@"From nil", ^{
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:nil fromPropertyName:@"nonCollectionProperty" forObject:object];
            [[finalValue should] beNil];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:[NSNull null] fromPropertyName:@"nonCollectionProperty" forObject:object];
            [[finalValue should] equal:[NSNull null]];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:nil fromPropertyName:@"setProperty" forObject:object];
            [[finalValue should] beNil];
        });
        
        specify(^{
            id finalValue = [WAPropertyTransformation propertyValue:[NSNull null] fromPropertyName:@"setProperty" forObject:object];
            [[finalValue should] beKindOfClass:[NSSet class]];
            [[finalValue should] haveCountOf:1];
        });
    });
});

SPEC_END