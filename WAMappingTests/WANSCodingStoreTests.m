//
//  WANSCodingStoreTests.m
//  WAMapping
//
//  Created by Marian Paul on 26/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "Kiwi.h"

#import "WAEntityMapping.h"
#import "WARelationshipMapping.h"
#import "WANSCodingStore.h"

#import "Enterprise.h"
#import "Employee.h"

SPEC_BEGIN(WANSCodingStoreTests)

describe(@"WANSCodingStoreTests", ^{
    
    describe(@"mapFromRepresentation", ^{
        __block WAEntityMapping *enterpriseMapping = nil;
        __block WAEntityMapping *employeeMapping = nil;
        
        __block WANSCodingStore *store = nil;
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *archivePath = [libraryPath stringByAppendingString:@"test.archive"];
        
        [[NSFileManager defaultManager] removeItemAtPath:archivePath
                                                   error:nil];
        
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
            
            WARelationshipMapping *employeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"employees" toDestinationProperty:@"employees" withMapping:employeeMapping];
            [enterpriseMapping addRelationshipMapping:employeesRelationship];
            
            store = [[WANSCodingStore alloc] initWithArchivePath:archivePath];
        });
        
        context(@"Create enterprise with employees and fetch it", ^{
            __block Enterprise *enterprise = nil;
            
            beforeAll(^{
                [store beginTransaction];
                
                enterprise = [store newObjectForMapping:enterpriseMapping];
                enterprise.itemID = @1;
                enterprise.name = @"Wasappli";
                
                Employee *employee = [store newObjectForMapping:employeeMapping];
                employee.itemID = @1;
                employee.firstName = @"Marian";
                
                enterprise.employees = @[employee];
                
                [store commitTransaction];
            });
            
            specify(^{
                [[enterprise shouldNot] beNil];
            });
            
            specify(^{
                [store beginTransaction];
                NSArray *enterprises = [store objectsWithAttributes:@[@1] forMapping:enterpriseMapping];
                [store commitTransaction];
                
                [[enterprises should] haveCountOf:1];
                Enterprise *wasappli = [enterprises firstObject];
                [[wasappli.itemID should] equal:@1];
                [[wasappli.employees should] haveCountOf:1];
            });
            
            specify(^{
                [store beginTransaction];
                NSArray *employees = [store objectsWithAttributes:@[@1] forMapping:employeeMapping];
                [store commitTransaction];

                [[employees should] haveCountOf:1];
                Employee *marian = [employees firstObject];
                [[marian.itemID should] equal:@1];
            });
        });
        
        context(@"Fetch employees on new store", ^{
            __block WANSCodingStore *secondStore = nil;
            
            beforeAll(^{
                secondStore = [[WANSCodingStore alloc] initWithArchivePath:archivePath];
            });
            
            specify(^{
                [[secondStore shouldNot] equal:store];
            });
            
            specify(^{
                // Before beginning transaction, no data
                NSArray *enterprises = [secondStore objectsWithAttributes:@[@1] forMapping:enterpriseMapping];
                [enterprises shouldBeNil];
            });
            
            specify(^{
                [secondStore beginTransaction];
                NSArray *enterprises = [secondStore objectsWithAttributes:@[@1] forMapping:enterpriseMapping];
                [secondStore commitTransaction];
                
                [[enterprises should] haveCountOf:1];
                Enterprise *wasappli = [enterprises firstObject];
                [[wasappli.itemID should] equal:@1];
                [[wasappli.employees should] haveCountOf:1];
            });
            
            specify(^{
                [secondStore beginTransaction];
                NSArray *employees = [secondStore objectsWithAttributes:@[@1] forMapping:employeeMapping];
                [secondStore commitTransaction];
                
                [[employees should] haveCountOf:1];
                Employee *marian = [employees firstObject];
                [[marian.itemID should] equal:@1];
            });
        });
        
        context(@"Delete employee", ^{
            specify(^{
                [store beginTransaction];
                NSArray *enterprises = [store objectsWithAttributes:@[@1] forMapping:enterpriseMapping];
                Enterprise *wasappli = [enterprises firstObject];
                Employee *marian = [wasappli.employees firstObject];
                [store deleteObject:marian];
                wasappli.employees = nil;
                [store commitTransaction];
                
                [store beginTransaction];
                NSArray *employees = [store objectsWithAttributes:@[@1] forMapping:employeeMapping];
                [store commitTransaction];

                [[employees should] haveCountOf:0];
            });
            
            specify(^{
                WANSCodingStore *secondStore = [[WANSCodingStore alloc] initWithArchivePath:archivePath];
                
                [secondStore beginTransaction];
                NSArray *employees = [secondStore objectsWithAttributes:@[@1] forMapping:employeeMapping];
                [secondStore commitTransaction];
                
                [[employees should] haveCountOf:0];
            });
        });
    });
});

SPEC_END
