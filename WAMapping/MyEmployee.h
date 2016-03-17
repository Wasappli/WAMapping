//
//  MyEmployee.h
//  WAMapping
//
//  Created by Marian Paul on 16-03-17.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyEnterprise;

@interface MyEmployee : NSObject

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) MyEnterprise *enterprise;
@property (nonatomic, strong) NSDate *birthDate;

@end
