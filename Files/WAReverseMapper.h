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

typedef BOOL (^WAReverseMapperShouldMapRelationshipBlock)(NSString *_Nonnull sourceRelationShip);

/**
 *  This class performs a reverse mapper by turning objects back into dictionaries
 *  It supports NSProgress with cancellation (but no pausing). The class mimics `NSProgressReporting` available from iOS 9. Be aware that according to Apple Documentation about `NSProgressReporting`, "Objects that adopt this protocol should typically be "one-shot"". This principle applies here as well. This means that you should allocate one reversemapper per mapping execution
 */
@interface WAReverseMapper : NSObject

/**
 *  Turns objects into a dictionary
 *
 *  @param objects                    the objects you need to turns into dictionary
 *  @param mapping                    the mapping used to reverse map the objects
 *  @param shouldMapRelationshipBlock a block called if you want to avoid some relationships to be reversed mapped. Map everything by default.
 *
 *  @return an array of dictionary which are a representation of the objects
 */
- (NSArray <NSDictionary *>*_Nullable)reverseMapObjects:(NSArray *_Nonnull)objects fromMapping:(WAEntityMapping *_Nonnull)mapping shouldMapRelationship:(_Nullable WAReverseMapperShouldMapRelationshipBlock)shouldMapRelationshipBlock error:(NSError *_Nullable*_Nullable)error;

/**
 *  Add a reverse default mapping block for a class. For example, you could have an API returning dates all with the same format. You can register the transformation once here.
 *
 *  @param reverseMappingBlock the reverse mapping block called to transform the value
 *  @param destinationClass    the destination class
 */
- (void)addReverseDefaultMappingBlock:(_Nonnull WAMappingBlock)reverseMappingBlock forDestinationClass:(_Nonnull Class)destinationClass;

@property (strong, readonly) NSProgress *_Nullable progress;

@end
