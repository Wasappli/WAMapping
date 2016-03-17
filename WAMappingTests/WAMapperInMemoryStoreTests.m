//
//  WAMapperInMemoryStoreTests.m
//  WAMapping
//
//  Created by Marian Paul on 02/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Kiwi.h"

#import "WAEntityMapping.h"
#import "WARelationshipMapping.h"
#import "WAMapper.h"
#import "WAMemoryStore.h"

#import "Enterprise.h"
#import "Employee.h"

SPEC_BEGIN(WAMapperInMemoryStoreTests)

describe(@"WAMapperInMemoryStoreTests", ^{
    
    describe(@"mapFromRepresentation", ^{
        __block WAEntityMapping *enterpriseMapping = nil;
        __block WAEntityMapping *employeeMapping = nil;
        
        __block WARelationshipMapping *employeesRelationship = nil;
        
        __block WAMemoryStore *store = nil;
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
                                                                    @"address.street_number": @"streetNumber"
                                                                    }];
            
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
            
            WARelationshipMapping *enterpriseRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"enterprise" toDestinationProperty:@"enterprise" withMapping:enterpriseMapping];
            [employeeMapping addRelationshipMapping:enterpriseRelationship];
            
            store = [[WAMemoryStore alloc] init];
            mapper = [[WAMapper alloc] initWithStore:store];
        });
        
        context(@"Classic enterprise", ^{
            __block Enterprise *enterprise = nil;
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise should] beKindOfClass:[Enterprise class]];
            });
            
            specify(^{
                [[enterprise.name should] equal:json[@"name"]];
            });
            
            specify(^{
                [[enterprise.streetNumber should] equal:json[@"address"][@"street_number"]];
            });
            
            specify(^{
                [[enterprise.creationDate should] beKindOfClass:[NSDate class]];
                [[enterprise.creationDate should] equal:[dateFormatter dateFromString:json[@"creation_date"]]];
            });
        });
        
        context(@"Update with null property", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullName" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
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
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNoName" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
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
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNullAddress" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
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
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
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
                Employee *employee = [enterprise.employees firstObject];
                [[employee.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with one employee as relation ship from attribute", ^{
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneChief" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects, NSError *error) {
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
                Employee *chief = [enterprise.chiefs firstObject];
                [[chief.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with several employees as relation ship from attribute", ^{
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects, NSError *error) {
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
                Employee *chief = [enterprise.chiefs firstObject];
                [[chief.firstName should] equal:@"Marian"];
            });
        });
        
        context(@"Enterprise with null employees as relation ship from attribute", ^{
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNullChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects, NSError *error) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs should] beNil];
            });
        });
        
        context(@"Enterprise with nil employees as relation ship from attribute", ^{
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithNilChiefs" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json[@"employees"]
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       [mapper mapFromRepresentation:json[@"enterprise"]
                                                             mapping:enterpriseMapping
                                                          completion:^(NSArray *mappedObjects, NSError *error) {
                                                              enterprise = [mappedObjects firstObject];
                                                          }];
                                   }];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise.chiefs should] beNil];
            });
        });
        
        context(@"Employee with it's enterprise", ^{
            __block Employee *employee = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:employeeMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       employee = [mappedObjects firstObject];
                                   }];
            });
            
            specify(^{
                [[employee shouldNot] beNil];
            });
            
            specify(^{
                [[employee.enterprise shouldNot] beNil];
                [[employee.enterprise should] beKindOfClass:[Enterprise class]];
            });
            
            specify(^{
                Enterprise *enterprise = employee.enterprise;
                [[enterprise.name should] equal:@"Wasappli"];
            });
        });
        
        context(@"Enterprise with ordered employees", ^{
            __block Enterprise *enterprise = nil;
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOrderedEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise should] beMemberOfClass:[Enterprise class]];
            });
            
            specify(^{
                [[enterprise.orderedEmployees should] beKindOfClass:[NSOrderedSet class]];
                [[enterprise.orderedEmployees should] haveCountOf:3]; // There is twice the same object
                [[[[enterprise.orderedEmployees firstObject] itemID] should] equal:@1];
            });
        });
        
        context(@"Update with null relation ship", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEmployeeWithAnEnterprise" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithNullEmployee" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees should] beNil];
            });
        });
        
        context(@"Update with missing relation ship", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
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
        
        context(@"Update with non numerical ids", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployeeNonNumericalIDS" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralEmployeesNonNumericalIDS" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees shouldNot] beNil];
                [[enterprise2.employees should] haveCountOf:3];
            });
            
            specify(^{
                Employee *employee = [enterprise2.employees firstObject];
                [[employee.firstName should] equal:@"Marian modified"];
            });
        });
        
        context(@"Update with merge policy", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyMerge;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees shouldNot] beNil];
                [[enterprise2.employees should] haveCountOf:3];
            });
            
            afterAll(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyAssign;
            });
        });
        
        context(@"Update with replace policy", ^{
            __block Enterprise *enterprise1 = nil;
            __block Enterprise *enterprise2 = nil;
            
            beforeAll(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyReplace;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterpriseWithOneEmployee" ofType:@"json"];
                
                id json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise1 = [mappedObjects firstObject];
                                   }];
                
                path = [bundle pathForResource:@"ClassicEnterpriseWithSeveralEmployees" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise2 = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise1 should] equal:enterprise2];
            });
            
            specify(^{
                [[enterprise2.employees shouldNot] beNil];
                [[enterprise2.employees should] haveCountOf:2];
            });
            
            afterAll(^{
                employeesRelationship.relationshipPolicy = WARelationshipPolicyAssign;
            });
        });
        
        context(@"Classic enterprise without identification attribute", ^{
            __block Enterprise *enterprise = nil;
            __block NSDictionary *json = nil;
            
            beforeAll(^{
                enterpriseMapping.identificationAttribute = nil;
                
                NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                NSString *path = [bundle pathForResource:@"ClassicEnterprise" ofType:@"json"];
                
                json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
                [mapper mapFromRepresentation:json
                                      mapping:enterpriseMapping
                                   completion:^(NSArray *mappedObjects, NSError *error) {
                                       enterprise = [mappedObjects firstObject];
                                   }];
                
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [[enterprise should] beMemberOfClass:[Enterprise class]];
            });
            
            specify(^{
                [[enterprise.name should] equal:json[@"name"]];
            });
            
            specify(^{
                [[enterprise.streetNumber should] equal:json[@"address"][@"street_number"]];
            });
            
            specify(^{
                [[enterprise.creationDate should] beKindOfClass:[NSDate class]];
                [[enterprise.creationDate should] equal:[dateFormatter dateFromString:json[@"creation_date"]]];
            });
            
            afterAll(^{
                enterpriseMapping.identificationAttribute = @"itemID";
            });
        });
    });
});

SPEC_END
