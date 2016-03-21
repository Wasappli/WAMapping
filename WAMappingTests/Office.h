//
//  Office.h
//  WAMapping
//
//  Created by Marian Paul on 16-03-21.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Employee;

@interface Office : NSObject

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) Employee *advisor;

@end
