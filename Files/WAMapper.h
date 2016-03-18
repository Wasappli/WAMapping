//
//  WAMapper.h
//  WAMapping
//
//  Created by Marian Paul on 01/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WABlockMapping.h"

@class WAEntityMapping;
@protocol WAStoreProtocol;

typedef void (^WAMapperProgressBlock)(NSProgress *progress);
typedef void (^WAMapperCompletionBlock)(NSArray *mappedObjects, NSError *error);

/**
 This class will transform a dictionary representation to an object
 It supports NSProgress with cancellation (but no pausing). The class mimics `NSProgressReporting` available from iOS 9. Be aware that according to Apple Documentation about `NSProgressReporting`, "Objects that adopt this protocol should typically be "one-shot"". This principle applies here as well.
 This means that you should allocate one mapper per mapping execution
*/
@interface WAMapper : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Init the mapper with a store
 *
 *  @param store a store which is used to perform operations on mapped objects
 *
 *  @return an instance of the mapper
 */
- (instancetype)initWithStore:(id <WAStoreProtocol>)store NS_DESIGNATED_INITIALIZER;

/**
 *  @see `initWithStore:`
 */
+ (instancetype)newMapperWithStore:(id <WAStoreProtocol>)store;

/**
 *  Map a dictionary representation to the objects
 *
 *  @param json       the dictionary which represents the objects
 *  @param mapping    the mapping used to map the objects
 *  @param completion a completion block called when all objects have been mapped
 */
- (void)mapFromRepresentation:(id)json mapping:(WAEntityMapping *)mapping completion:(WAMapperCompletionBlock)completion;

/**
 *  Add a default mapping block for a class. For example, you could have an API returning dates all with the same format. You can register the transformation once here.
 *
 *  @param mappingBlock     the mapping block called to transform the value
 *  @param destinationClass the destination class
 */
- (void)addDefaultMappingBlock:(WAMappingBlock)mappingBlock forDestinationClass:(Class)destinationClass;

@property (nonatomic, strong, readonly) id <WAStoreProtocol> store;

@property (strong, readonly) NSProgress *progress;

@end
