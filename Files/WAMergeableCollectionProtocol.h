//
//  WAMergeableCollectionProtocol.h
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@protocol WAMergeableCollectionProtocol <NSObject>

- (instancetype)wa_collectionMergedWith:(id <WAMergeableCollectionProtocol>)toMerge;
- (instancetype)wa_collectionMinus:(id <WAMergeableCollectionProtocol>)toRemove;

@end
