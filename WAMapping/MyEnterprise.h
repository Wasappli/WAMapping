//
//  MyEnterprise.h
//  WAMapping
//
//  Created by Marian Paul on 16-03-17.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEnterprise : NSObject

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *streetNumber;
@property (nonatomic, strong) NSArray *employees;

@end
