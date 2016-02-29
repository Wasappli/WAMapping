//
//  WAReverseMapperMemoryTests.m
//  WAMapping
//
//  Created by Marian Paul on 22/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Kiwi.h"

#import "WAEntityMapping.h"
#import "WARelationshipMapping.h"
#import "WAReverseMapper.h"
#import "WAMemoryStore.h"

#import "Enterprise.h"
#import "Employee.h"

SPEC_BEGIN(WAReverseMapperMemoryTests)

describe(@"WAReverseMapperMemoryTests", ^{
    
    describe(@"mapFromRepresentation", ^{
        __block WAEntityMapping *enterpriseMapping = nil;
        __block WAEntityMapping *employeeMapping = nil;
        
        __block WARelationshipMapping *employeesRelationship = nil;
        
        __block WAMemoryStore *store = nil;
        __block WAReverseMapper *reverseMapper = nil;
        
        __block Enterprise *enterprise = nil;
        __block Employee *firstEmployee = nil;
        __block Employee *secondEmployee = nil;
        
        NSDateFormatter *defaultDateFormatter = [NSDateFormatter new];
        [defaultDateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *birthDateFormatter = [NSDateFormatter new];
        [birthDateFormatter setDateFormat:@"yyyy"];
        
        beforeAll(^{
            enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
            employeeMapping = [WAEntityMapping mappingForEntityName:@"Employee"];
            
            enterpriseMapping.identificationAttribute = @"itemID";
            employeeMapping.identificationAttribute = @"itemID";
            
            [enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                                    @"id": @"itemID",
                                                                    @"name": @"name",
                                                                    @"address.street_number": @"streetNumber",
                                                                    @"creation_date": @"creationDate"}];
            
            [employeeMapping addAttributeMappingsFromDictionary:@{@"id": @"itemID",
                                                                  @"first_name": @"firstName"}];
            
            [employeeMapping addMappingFromSourceProperty:@"birth_date"
                                      toDestinationProperty:@"birthDate"
                                                  withBlock:^id(id value) {
                                                      return [birthDateFormatter dateFromString:value];
                                                  }
                                               reverseBlock:^id(id value) {
                                                   return [birthDateFormatter stringFromDate:value];
                                               }];
            
            employeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"employees" toDestinationProperty:@"employees" withMapping:employeeMapping];
            WARelationshipMapping *orderedEmployeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"ordered_employees" toDestinationProperty:@"orderedEmployees" withMapping:employeeMapping];
            
            WARelationshipMapping *chiefsRelationship = [WARelationshipMapping relationshipMappingFromSourceIdentificationAttribute:@"chiefs" toDestinationProperty:@"chiefs" withMapping:employeeMapping];
            
            [enterpriseMapping addRelationshipMapping:employeesRelationship];
            [enterpriseMapping addRelationshipMapping:orderedEmployeesRelationship];
            [enterpriseMapping addRelationshipMapping:chiefsRelationship];
            
            WARelationshipMapping *enterpriseRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"enterprise" toDestinationProperty:@"enterprise" withMapping:enterpriseMapping];
            [employeeMapping addRelationshipMapping:enterpriseRelationship];
            
            store = [[WAMemoryStore alloc] init];
            reverseMapper = [[WAReverseMapper alloc] init];
            
            id(^fromDateMappingBlock)(id ) = ^id(id value) {
                if ([value isKindOfClass:[NSDate class]]) {
                    return [defaultDateFormatter stringFromDate:value];
                }
                
                return value;
            };
            
            [reverseMapper addReverseDefaultMappingBlock:fromDateMappingBlock
                                     forDestinationClass:[NSDate class]];
            
            enterprise = [store newObjectForMapping:enterpriseMapping];
            enterprise.name = @"Wasappli";
            enterprise.streetNumber = @5149;
            enterprise.creationDate = [NSDate dateWithTimeIntervalSince1970:194333434];
            
            firstEmployee = [store newObjectForMapping:employeeMapping];
            firstEmployee.firstName = @"Marian";
            firstEmployee.birthDate = [NSDate dateWithTimeIntervalSince1970:194333434];
            
            secondEmployee = [store newObjectForMapping:employeeMapping];
            secondEmployee.firstName = @"Jérémy";
        });
        
        context(@"Classic enterprise", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                json = [[reverseMapper reverseMapObjects:@[enterprise]
                                            fromMapping:enterpriseMapping
                                  shouldMapRelationship:nil] firstObject];
            });
            
            specify(^{
                [[json shouldNot] beNil];
            });
            
            specify(^{
                [[json should] beKindOfClass:[NSDictionary class]];
            });
            
            specify(^{
                [[json[@"name"] should] equal:@"Wasappli"];
            });
            
            specify(^{
                [[json[@"address"][@"street_number"] should] equal:@5149];
            });
            
            specify(^{
                [[json[@"creation_date"] should] equal:@"1976-02-28"];
            });
            
            specify(^{
                NSArray *employees = json[@"employees"];
                [[employees should] equal:[NSNull null]];
            });
        });
        
        context(@"Enterprise with employees", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                enterprise.employees = @[firstEmployee, secondEmployee];
                
                json = [[reverseMapper reverseMapObjects:@[enterprise]
                                             fromMapping:enterpriseMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                NSArray *employees = json[@"employees"];
                [[employees shouldNot] beNil];
                [[employees should] haveCountOf:2];
                [[[employees firstObject][@"first_name"] should] equal:@"Marian"];
                [[[employees firstObject][@"birth_date"] should] equal:@"1976"];
            });
            
            afterAll(^{
                enterprise.employees = nil;
            });
        });
        
        context(@"Enterprise with id with employees", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                enterprise.employees = @[firstEmployee, secondEmployee];
                firstEmployee.enterprise = enterprise;
                secondEmployee.enterprise = enterprise;
                enterprise.itemID = @1;
                
                json = [[reverseMapper reverseMapObjects:@[enterprise]
                                             fromMapping:enterpriseMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                NSArray *employees = json[@"employees"];
                [[[employees firstObject][@"enterprise"][@"id"] should] equal:@1];
            });
            
            afterAll(^{
                enterprise.employees = nil;
                enterprise.itemID = nil;
                firstEmployee.enterprise = nil;
                secondEmployee.enterprise = nil;
            });
        });

        context(@"Enterprise with id with employees with ids", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                firstEmployee.itemID = @1;
                secondEmployee.itemID = @2;
                enterprise.employees = @[firstEmployee, secondEmployee];
                enterprise.itemID = @1;
                firstEmployee.enterprise = enterprise;
                secondEmployee.enterprise = enterprise;
                
                json = [[reverseMapper reverseMapObjects:@[enterprise]
                                             fromMapping:enterpriseMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                NSArray *employees = json[@"employees"];
                [[[employees firstObject][@"enterprise"][@"id"] should] equal:@1];
            });
            
            afterAll(^{
                enterprise.employees = nil;
                enterprise.itemID = nil;
                firstEmployee.itemID = nil;
                secondEmployee.itemID = nil;
                firstEmployee.enterprise = nil;
                secondEmployee.enterprise = nil;
            });
        });
        
        context(@"Classic enterprise with relationship employees forbidden", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                json = [[reverseMapper reverseMapObjects:@[enterprise]
                                             fromMapping:enterpriseMapping
                                   shouldMapRelationship:^BOOL(NSString *sourceRelationShip) {
                                       if ([sourceRelationShip isEqualToString:@"employees"]) {
                                           return NO;
                                       }
                                       return YES;
                                   }] firstObject];
                
            });
            
            specify(^{
                [[json shouldNot] beNil];
            });
            
            specify(^{
                [[json should] beKindOfClass:[NSDictionary class]];
            });
            
            specify(^{
                [[json[@"name"] should] equal:@"Wasappli"];
            });
            
            specify(^{
                [[json[@"address"][@"street_number"] should] equal:@5149];
            });
            
            specify(^{
                [[json[@"creation_date"] should] equal:@"1976-02-28"];
            });
            
            specify(^{
                NSArray *employees = json[@"employees"];
                [[employees should] beNil];
            });
        });
        
        context(@"Employee with no id", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                json = [[reverseMapper reverseMapObjects:@[firstEmployee]
                                             fromMapping:employeeMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                [[json shouldNot] beNil];
            });
            
            specify(^{
                [[json should] beKindOfClass:[NSDictionary class]];
            });
            
            specify(^{
                [[json[@"first_name"] should] equal:@"Marian"];
            });
            
            specify(^{
                NSDictionary *enterprise = json[@"enterprise"];
                [[enterprise should] equal:[NSNull null]];
            });
        });

        context(@"Employee with no id with enterprise", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                firstEmployee.enterprise = enterprise;
                json = [[reverseMapper reverseMapObjects:@[firstEmployee]
                                             fromMapping:employeeMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                NSDictionary *enterprise = json[@"enterprise"];
                [[enterprise shouldNot] beNil];
                [[enterprise[@"name"] should] equal:@"Wasappli"];
            });
            
            afterAll(^{
                firstEmployee.enterprise = nil;
            });
        });
        
        
        context(@"Employee with id with enterprise", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                firstEmployee.enterprise = enterprise;
                firstEmployee.itemID = @1;
                json = [[reverseMapper reverseMapObjects:@[firstEmployee]
                                             fromMapping:employeeMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                [[json[@"id"] should] equal:@1];
            });
            
            specify(^{
                NSDictionary *enterprise = json[@"enterprise"];
                [[enterprise shouldNot] beNil];
                [[enterprise[@"name"] should] equal:@"Wasappli"];
            });
            
            afterAll(^{
                firstEmployee.enterprise = nil;
                firstEmployee.itemID = nil;
            });
        });
        
        context(@"Employee with id with enterprise with employees", ^{
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                firstEmployee.enterprise = enterprise;
                secondEmployee.enterprise = enterprise;
                enterprise.employees = @[firstEmployee, secondEmployee];
                firstEmployee.itemID = @1;
                
                json = [[reverseMapper reverseMapObjects:@[firstEmployee]
                                             fromMapping:employeeMapping
                                   shouldMapRelationship:nil] firstObject];
                
            });
            
            specify(^{
                [[json[@"id"] should] equal:@1];
            });
            
            specify(^{
                NSDictionary *enterprise = json[@"enterprise"];
                [[enterprise shouldNot] beNil];
                [[enterprise[@"name"] should] equal:@"Wasappli"];
                [[enterprise[@"employees"] should] haveCountOf:2];
            });
            
            afterAll(^{
                firstEmployee.enterprise = nil;
                secondEmployee.enterprise = nil;
                enterprise.employees = nil;
                firstEmployee.itemID = nil;
            });
        });
    });
});

SPEC_END
