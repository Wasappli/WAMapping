//
//  WARelationshipMapping.h
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@class WAEntityMapping;

typedef enum : NSUInteger {
    WARelationshipPolicyAssign, // Default. Replace the pointers. Do not delete previous value from store
    WARelationshipPolicyMerge, // 1to1 -> replace. toMany -> add the received objects
    WARelationshipPolicyReplace, // Delete previous object and assign new ones
} WARelationshipPolicy;

/**
 This class represents a relation ship between two objects
*/
@interface WARelationshipMapping : NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  This is the classic relation ship. eg: `{employees: [{"name": "first employee"}, {"name": "second employee"}]}`
 *
 *  @param sourceProperty      the source property name (on dictionary)
 *  @param destinationProperty the destination property name (on object)
 *  @param mapping             the mapping of the destination entity
 *
 *  @return a relationship mapping instance
 */
- (instancetype _Nonnull)initWithSourceProperty:(NSString *_Nonnull)sourceProperty destinationProperty:(NSString *_Nonnull)destinationProperty mapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  @see `initWithSourceProperty: destinationProperty: mapping:`
 */
+ (instancetype _Nonnull)relationshipMappingFromSourceProperty:(NSString *_Nonnull)sourceProperty toDestinationProperty:(NSString *_Nonnull)destinationProperty withMapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  This is the second behavior offered for a relation ship. eg: `{employees: [1, 2]}` or `{chief: 1}`
 *
 *  @param sourceIdentificationAttribute the source identification property name
 *  @param destinationProperty           the destination property name (on object)
 *  @param mapping                       the mapping of the destination entity
 *
 *  @return a relation ship mapping instance
 */
- (instancetype _Nonnull)initWithSourceIdentificationAttribute:(NSString *_Nonnull)sourceIdentificationAttribute destinationProperty:(NSString *_Nonnull)destinationProperty mapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  @see `initWithSourceIdentificationAttribute: destinationProperty: mapping:`
 */
+ (instancetype _Nonnull)relationshipMappingFromSourceIdentificationAttribute:(NSString *_Nonnull)sourceIdentificationAttribute toDestinationProperty:(NSString *_Nonnull)destinationProperty withMapping:(WAEntityMapping *_Nonnull)mapping;

/**
 *  The relation ship policy. Default is `WARelationshipPolicyAssign`
 *  Values are:
 *  - `WARelationshipPolicyAssign`  -> Replace the pointers without deleting objects from store
 *  - `WARelationshipPolicyMerge`   -> Replace the object if 1to1 relation ship, or merge if collection
 *  - `WARelationshipPolicyReplace` -> Delete the previous object from store and assign new ones
 */
@property (nonatomic, assign) WARelationshipPolicy relationshipPolicy;

@property (nonatomic, readonly) NSString        *_Nullable sourceProperty;
@property (nonatomic, readonly) NSString        *_Nullable sourceIdentificationAttribute;
@property (nonatomic, readonly) NSString        *_Nonnull destinationProperty;
@property (nonatomic, readonly) WAEntityMapping *_Nonnull mapping;

@end
