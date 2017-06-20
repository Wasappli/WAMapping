//
//  WAMergeableCollectionProtocol.h
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

@import Foundation;

@protocol WAMergeableCollectionProtocol <NSObject>

- (instancetype _Nonnull)wa_collectionMergedWith:(_Nonnull id <WAMergeableCollectionProtocol>)toMerge;
- (instancetype _Nonnull)wa_collectionMinus:(_Nonnull id <WAMergeableCollectionProtocol>)toRemove;

@end
