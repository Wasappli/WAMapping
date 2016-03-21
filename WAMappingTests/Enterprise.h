//
//  Enterprise.h
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enterprise : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *streetNumber;
@property (nonatomic, strong) NSArray *employees;
@property (nonatomic, strong) NSOrderedSet *orderedEmployees;
@property (nonatomic, strong) NSArray *chiefs;
@property (nonatomic, strong) NSArray *offices;

@end
