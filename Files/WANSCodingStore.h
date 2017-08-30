//
//  WANSCodingStore.h
//  WAMapping
//
//  Created by Marian Paul on 26/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WAStoreProtocol.h"

/**
 *  An NSCoding store. Save objects into an archive
 */
@interface WANSCodingStore : NSObject <WAStoreProtocol>

- (instancetype _Nonnull)init NS_UNAVAILABLE;
+ (instancetype _Nonnull)new NS_UNAVAILABLE;

/**
 *  Init the store with an archive path used to store all your objects
 *
 *  @param archivePath the path to the archive. Usually a file on library folder
 *
 *  @return an NSCoding store
 */
- (instancetype _Nonnull)initWithArchivePath:(NSString *_Nonnull)archivePath NS_DESIGNATED_INITIALIZER;

@end
