//
//  ViewController.m
//  WAMapping
//
//  Created by Marian Paul on 27/01/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#import "ViewController.h"
#import "WAMapping.h"
#import "MyEnterprise.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure Mapper
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    WAEntityMapping *enterpriseMapping = [WAEntityMapping mappingForEntityName:@"MyEnterprise"];
    WAEntityMapping *employeeMapping   = [WAEntityMapping mappingForEntityName:@"MyEmployee"];

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
    
    WARelationshipMapping *employeesRelationship        = [WARelationshipMapping relationshipMappingFromSourceProperty:@"employees" toDestinationProperty:@"employees" withMapping:employeeMapping];
    WARelationshipMapping *orderedEmployeesRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"ordered_employees" toDestinationProperty:@"orderedEmployees" withMapping:employeeMapping];
    
    WARelationshipMapping *chiefsRelationship = [WARelationshipMapping relationshipMappingFromSourceIdentificationAttribute:@"chiefs" toDestinationProperty:@"chiefs" withMapping:employeeMapping];
    
    [enterpriseMapping addRelationshipMapping:employeesRelationship];
    [enterpriseMapping addRelationshipMapping:orderedEmployeesRelationship];
    [enterpriseMapping addRelationshipMapping:chiefsRelationship];
    
    WARelationshipMapping *enterpriseRelationship = [WARelationshipMapping relationshipMappingFromSourceProperty:@"enterprise" toDestinationProperty:@"enterprise" withMapping:enterpriseMapping];
    [employeeMapping addRelationshipMapping:enterpriseRelationship];
    
    WAMemoryStore *store = [[WAMemoryStore alloc] init];
    WAMapper *mapper     = [[WAMapper alloc] initWithStore:store];
    
    // Observe changes to progress
    [mapper.progress addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    // Map
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Enterprises" ofType:@"json"]];
    id JSON      = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [mapper mapFromRepresentation:JSON mapping:enterpriseMapping completion:^(NSArray *mappedObjects, NSError *error) {
        NSLog(@"Mapped %@", mappedObjects);
        NSLog(@"Mapped enterprises %@", [mappedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.class == %@", [MyEnterprise class]]]);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isKindOfClass:[NSProgress class]]) {
        NSLog(@"Mapping progress = %f", [change[@"new"] doubleValue]);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
