//
//  WAReverseMapper.h
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WABlockMapping.h"

@class WAEntityMapping;

typedef BOOL (^WAReverseMapperShouldMapRelationshipBlock)(NSString *sourceRelationShip);

/**
 *  This class performs a reverse mapper by turning objects back into dictionaries
 *  It supports NSProgress with cancellation (but no pausing). Be aware that according to Apple Documentation about `NSProgressReporting`, "Objects that adopt this protocol should typically be "one-shot""
 *  This means that you should allocate one reversemapper per execution
 */
@interface WAReverseMapper : NSObject <NSProgressReporting>

/**
 *  Turns objects into a dictionary
 *
 *  @param objects               the objects you need to turns into dictionary
 *  @param mapping               the mapping used to reverse map the objects
 *  @param shouldMapRelationship a block called if you want to avoid some relationships to be reversed mapped. Map everything by default.
 *
 *  @return an array of dictionary which are a representation of the objects
 */
- (NSArray <NSDictionary *>*)reverseMapObjects:(NSArray *)objects fromMapping:(WAEntityMapping *)mapping shouldMapRelationship:(WAReverseMapperShouldMapRelationshipBlock)shouldMapRelationshipBlock error:(NSError **)error;

/**
 *  Add a reverse default mapping block for a class. For example, you could have an API returning dates all with the same format. You can register the transformation once here.
 *
 *  @param reverseMappingBlock the reverse mapping block called to transform the value
 *  @param destinationClass    the destination class
 */
- (void)addReverseDefaultMappingBlock:(WAMappingBlock)reverseMappingBlock forDestinationClass:(Class)destinationClass;

@end
