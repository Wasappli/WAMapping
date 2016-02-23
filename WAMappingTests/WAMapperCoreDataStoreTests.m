//
//  WAMapperCoreDataStoreTests.m
//  WAMapping
//
//  Created by Marian Paul on 16-02-16.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Kiwi.h"

#import "WAEntityMapping.h"
#import "WARelationshipMapping.h"
#import "WAMapper.h"
#import "WACoreDataStore.h"

#import "EnterpriseCD.h"
#import "EmployeeCD.h"

#import <MagicalRecord/MagicalRecord.h>

SPEC_BEGIN(WAMapperCoreDataStoreTests)

describe(@"WAMapperCoreDataStoreTests", ^{
    
    describe(@"mapFromRepresentation", ^{
        __block WAEntityMapping *enterpriseMapping = nil;
        __block WAEntityMapping *employeeMapping = nil;
        
        __block WARelationshipMapping *employeesRelationship = nil;
        __block WARelationshipMapping *enterpriseRelationship = nil;

        __block WACoreDataStore *store = nil;
        __block WAMapper *mapper = nil;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        beforeAll(^{
            enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
            employeeMapping = [WAEntityMapping mappingForEntityName:@"Employee"];
            
            enterpriseMapping.identificationAttribute = @"itemID";
            employeeMapping.identificationAttribute = @"itemID";
            
            [enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                                    @"id": @"itemID",
                                                                    @"name": @"name",
                                                                    @"address.street_number": @"streetNumber"}];
            
            [enterpriseMapping addMappingFromSourceProperty:@"creation_date"
                                           toDestinationProperty:@"creationDate"
                                                  withBlock:^id(id value) {
                                                      return [dateFormatter dateFromString:value];
                                                  }];
            
            [employeeMapping addAttributeMappingsFromDictionary:@{@"id": @"itemID",
                                                                  @"first_name": @"firstName"}];
            
            employeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"employees" toDestinationProperty:@"employees" withMapping:employeeMapping];
            WARelationshipMapping *orderedEmployeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"ordered_employees" toDestinationProperty:@"orderedEmployees" withMapping:employeeMapping];
            
            WARelationshipMapping *chiefsRelationship = [WARelationshipMapping relationshipMappingFromSourceIdentificationAttribute:@"chiefs" toDestinationProperty:@"chiefs" withMapping:employeeMapping];
            
            [enterpriseMapping addRelationshipMapping:employeesRelationship];
            [enterpriseMapping addRelationshipMapping:orderedEmployeesRelationship];
            [enterpriseMapping addRelationshipMapping:chiefsRelationship];
            
            enterpriseRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"enterprise" toDestinationProperty:@"enterprise" withMapping:enterpriseMapping];
            [employeeMapping addRelationshipMapping:enterpriseRelationship];
        });
        
        beforeEach(^{
            [MagicalRecord setDefaultModelFromClass:[self class]];
            [MagicalRecord setupCoreDataStackWithInMemoryStore];
            
            store = [[WACoreDataStore alloc] initWithManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
            mapper = [[WAMapper alloc] initWithStore:store];
        });
        
        afterEach(^{
            [MagicalRecord cleanUp];
        });
        
        context(@"Classic enterprise", ^{
            __block EnterpriseCD *enterprise = nil;
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
[mapper mapFromRepresentation:json
                      mapping:enterpriseMapping
                   completion:^(NSArray *mappedObjects) {
                       enterprise = [mappedObjects firstObject];
                   }];
                
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
                [[enterprise should] beMemberOfClass:[EnterpriseCD class]];
                [[enterprise.name should] equal:json[@"name"]];
                [[enterprise.streetNumber should] equal:json[@"address"][@"street_number"]];
                [[enterprise.creationDate should] beKindOfClass:[NSDate class]];
                [[enterprise.creationDate should] equal:[dateFormatter dateFromString:json[@"creation_date"]]];
            });
        });
        
        context(@"Update with null property", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullName" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.name should] beNil];
            });
        });
        
        context(@"Update with missing property", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNoName" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.name shouldNot] beNil];
            });
        });
        
        context(@"Update with null address", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNullAddress" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.streetNumber should] beNil];
            });
        });
        
        context(@"Enterprise with one employee", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.employees shouldNot] beEmpty];
            });
            
            specify(^{
                EmployeeCD *employee = [enterprise.employees anyObject];
                [[employee.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with one employee as relation ship from attribute", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneChief" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs shouldNot] beEmpty];
            });
            
            specify(^{
                EmployeeCD *chief = [enterprise.chiefs firstObject];
                [[chief.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with several employees as relation ship from attribute", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs shouldNot] beEmpty];
                [[enterprise.chiefs should] haveCountOf:3];
            });
            
            specify(^{
                EmployeeCD *chief = [enterprise.chiefs firstObject];
                [[chief.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with null employees as relation ship from attribute", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNullChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs should] beEmpty];
            });
        });
        
        context(@"Enterprise with nil employees as relation ship from attribute", ^{
            __block EnterpriseCD *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNilChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs should] beEmpty];
            });
        });
        
        context(@"Employee with it's enterprise", ^{
            __block EmployeeCD *employee = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
            });
            
            specify(^{
                [[employee shouldNot] beNil];
            });
            
            specify(^{
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise should] beMemberOfClass:[EnterpriseCD class]];
            });
            
            specify(^{
                EnterpriseCD *enterprise = employee.enterprise;
                [[enterprise.name should] equal:@"Wasappli"];
            });
        });
        
        context(@"Enterprise with ordered employees", ^{
            __block EnterpriseCD *enterprise = nil;
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOrderedEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise should] beMemberOfClass:[EnterpriseCD class]];
            });
            
            specify(^{
                [[enterprise.orderedEmployees should] beKindOfClass:[NSOrderedSet class]];
                [[enterprise.orderedEmployees should] haveCountOf:4];
                [[[[enterprise.orderedEmployees firstObject] itemID] should] equal:@1];
            });
        });
        
        context(@"Update with null relation ship", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees should] beEmpty];
            });
        });
        
        context(@"Update with missing relation ship", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees shouldNot] beNil];
            });
        });
        
        context(@"Update with merge policy several", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            specify(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyMerge;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];

                [[enterprise1 should] equal:enterprise2];
                [[enterprise2.employees shouldNot] beNil];
                [[enterprise2.employees should] haveCountOf:3];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@3];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNilEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
                [[enterprise2.employees should] haveCountOf:3];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@3];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];

                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
                [[enterprise2.employees should] haveCountOf:3];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@3];
            });
        });
        
        context(@"Update with replace policy several", ^{
            __block EnterpriseCD *enterprise1 = nil;
            __block EnterpriseCD *enterprise2 = nil;
            
            specify(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyReplace;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
                [[enterprise1 should] equal:enterprise2];
                [[enterprise2.employees shouldNot] beNil];
                [[enterprise2.employees should] haveCountOf:2];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@2];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNilEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
                [[enterprise2.employees should] haveCountOf:2];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@2];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
                [[enterprise2.employees should] haveCountOf:0];
                [[@([EmployeeCD MR_countOfEntitiesWithContext:store.context]) should] equal:@0];
            });
        });
        
        context(@"Update with merge policy single", ^{
            __block EmployeeCD *employee = nil;
            
            specify(^{
                enterpriseRelationship.relationshipPolicy = WARelationshipPolicyMerge;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];

                [[employee shouldNot] beNil];
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise should] beMemberOfClass:[EnterpriseCD class]];
                EnterpriseCD *enterprise = employee.enterprise;
                [[enterprise.name should] equal:@"Wasappli"];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@1];

                path = [bundle pathForResource:@"ClassicEmployeeWithAnOtherEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise.itemID should] equal:@2];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@2];
                
                path = [bundle pathForResource:@"ClassicEmployeeWithNilEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise shouldNot] beNil];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@2];
                
                path = [bundle pathForResource:@"ClassicEmployeeWithNullEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise should] beNil];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@2];
            });
        });
        
        context(@"Update with merge policy single", ^{
            __block EmployeeCD *employee = nil;
            
            specify(^{
                enterpriseRelationship.relationshipPolicy = WARelationshipPolicyReplace;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee shouldNot] beNil];
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise should] beMemberOfClass:[EnterpriseCD class]];
                EnterpriseCD *enterprise = employee.enterprise;
                [[enterprise.name should] equal:@"Wasappli"];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@1];
                
                path = [bundle pathForResource:@"ClassicEmployeeWithAnOtherEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise.itemID should] equal:@2];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@1];
                
                path = [bundle pathForResource:@"ClassicEmployeeWithNilEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise shouldNot] beNil];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@1];
                
                path = [bundle pathForResource:@"ClassicEmployeeWithNullEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects) {
                                       employee = [mappedObjects firstObject];
                                   }];
                
                [[employee.enterprise should] beNil];
                [[@([EnterpriseCD MR_countOfEntitiesWithContext:store.context]) should] equal:@0];
            });
        });
    });
});

SPEC_END