//
//  WAMemoryStore.h
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;
#import "WAStoreProtocol.h"

/**
 *  A in memory store. As simple as it sounds: no savings out of RAM
 */
@interface WAMemoryStore : NSObject <WAStoreProtocol>

@end
