# WAMapping

[![Version](https://img.shields.io/cocoapods/v/WAMapping.svg?style=flat)](http://cocoapods.org/pods/WAMapping)
[![License](https://img.shields.io/cocoapods/l/WAMapping.svg?style=flat)](http://cocoapods.org/pods/WAMapping)
[![Platform](https://img.shields.io/cocoapods/p/WAMapping.svg?style=flat)](http://cocoapods.org/pods/WAMapping)

**Developed and Maintained by [ipodishima](https://github.com/ipodishima) Founder & CTO at [Wasappli Inc](http://wasapp.li).**

**Sponsored by [Wisembly](http://wisembly.com/en/)**

A fast mapper from JSON to `NSObject`

- [x] Fast
- [x] Simple to write & read
- [x] Saves you many hours
- [x] Supports both JSON <-> `NSObject`
- [x] Designed for customisation
- [x] Built-in CoreData and Memory stores
- [x] Built-in insert or update object 

Go visit the [wiki](https://github.com/wasappli/WAMapping/wiki) for more details about `WAMapping` advanced use.

## Install and use
### Cocoapods
Use Cocoapods, this is the easiest way to install the mapper.

`pod 'WAMapping'`

`#import <WAMapping/WAMapping.h>`

### Setup mapping

On a classical use, the `source` is known as the response from a server turned into a dictionary and the `destination` is the destination object to apply the values, for example an `NSManagedObject`.

Let's assume the `Enterprise` class as follows:

```objc
@interface Enterprise : NSObject

@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *streetNumber;
@property (nonatomic, strong) NSArray *employees; // Can be mutable, or an `NSSet` or an `NSOrderedSet`

@end
```

The `itemID` ids your object on the store. This is not required but recommended to avoid creating duplicates.

Assuming a json
```
{
    "id": 1,
    "name": "Wasappli",
    "creation_date": "2013-10-01",
    "address": {
        "street_number": 5149
    }
}
```

The mapping would looks like

```objc
WAEntityMapping *enterpriseMapping = [WAEntityMapping mappingForEntityName:@"Enterprise"];
enterpriseMapping.identificationAttribute = @"itemID";

// Add the classic attributes
[enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                        @"id": @"itemID",
                                                        @"name": @"name",
                                                        @"address.street_number": @"streetNumber"
                                                        }];      
                                                   
// Map custom values. Here an `NSDate` from a string using an `NSDateTransformer`
[enterpriseMapping addMappingFromSourceProperty:@"creation_date"
                          toDestinationProperty:@"creationDate"
                                      withBlock:^id(id value) {
                                          return [dateFormatter dateFromString:value];
                                      }
                                   reverseBlock:^id(id value) {
                                       return [dateFormatter stringFromDate:value];
                                   }];

// Register the mapping for future use
WAMappingRegistrar *registrar = [WAMAppingRegistrar new];
[registrar registerMapping:enterpriseMapping];
// [registrar registerMapping:employeeMapping];
// WAEntityMapping *savedEnterpriseMapping = [registrar mappingForEntityName:@"Enterprise"];
```

And that's it...!

### Use the mapper

First, create a store. This is a required step.
I'm providing two stores on this repo: `WAMemoryStore` which relies on a simple `NSMutableSet` and `WACoreDataStore` which makes use of `CoreData`
You can easily create your own store if you want to use `NSCoding` for example, go checkout the wiki.

```objc
WAMemoryStore *store = [[WAMemoryStore alloc] init];

// or
// WACoreDataStore *store = [[WACoreDataStore alloc] initWithManagedObjectContext:localContext];
```

Then, allocate a mapper with the store

```objc
WAMapper *mapper = [[WAMapper alloc] initWithStore:store];
```

Finally, map the dictionary representation to the object:

```objc
[mapper mapFromRepresentation:json
                      mapping:enterpriseMapping
                   completion:^(NSArray *mappedObjects) {
                       firstEnterprise = [mappedObjects firstObject];
                   }];
```

And voilà!

### Add relation ships

`WAMapping` also supports relationships:

- classics:

```
{
    "id": 1,
    "first_name": "Marian",
    "enterprise": {
        "id": 1,
        "name": "Wasappli",
        "creation_date": "2013-10-01",
        "address": {
            "street_number": 5149
        }
    }
}
```

```objc
WARelationshipMapping *enterpriseRelationship = 
[WARelationshipMapping relationshipMappingFromSourceProperty:@"enterprise" toDestinationProperty:@"enterprise" withMapping:enterpriseMapping];
[employeeMapping addRelationshipMapping:enterpriseRelationship];
```

- With identification attribute only

```
{
    "enterprise": {
        "id": 1,
        "name": "Wasappli",
        "creation_date": "2013-10-01",
        "address": {
            "street_number": 5149
        },
        "chiefs": 1 # Could also be [1, 2, 3] 
    },
    "employees": [{
                  "id": 1,
                  "first_name": "Marian"
                  }]
}
```

```objc
WARelationshipMapping *chiefsRelationship = [WARelationshipMapping relationshipMappingFromSourceIdentificationAttribute:@"chiefs" toDestinationProperty:@"chiefs" withMapping:employeeMapping];
[enterpriseMapping addRelationshipMapping:chiefsRelationship];
```

## Reverse mapper
A reverse mapper is also packaged with this library. It supports the reverse transformation from an object to a dictionary.

```objc
WAReverseMapper *reverseMapper = [[WAReverseMapper alloc] init];

json = [reverseMapper reverseMapObjects:enterprises
                            fromMapping:enterpriseMapping
                  shouldMapRelationship:nil];
```
# Side notes
## TODOs

- [ ] Benchmark against popular mappers
- [ ] Add more tests for keypath handling, especially on relationship

## Inspiration
You'll find inspiration from [Restkit](https://github.com/RestKit/RestKit) and [FastEasyMapping](https://github.com/Yalantis/FastEasyMapping). These are both libraries I used on projects but with issues

#Contributing : Problems, Suggestions, Pull Requests?

Please open a new Issue [here](https://github.com/Wasappli/WAAppRouting/issues) if you run into a problem specific to WAAppRouting.

For new features pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing code style. If you're considering taking on significant changes or additions to the project, please ask me before by opening a new Issue to have a chance for a merge.

#That's all folks !

- If your are happy don't hesitate to send me a tweet [@ipodishima](http://twitter.com/ipodishima)!
- Distributed under MIT licence.
- Follow Wasappli on [facebook](https://www.facebook.com/wasappli)
