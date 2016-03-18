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
- [x] Built-in CoreData, NSCoding and Memory stores
- [x] Built-in insert or update object
- [x] Tested

Go visit the [wiki](https://github.com/wasappli/WAMapping/wiki) for more details about `WAMapping` advanced use.

WAMapping is a library for iOS to turns dictionaries into objects and objects to dictionary. It's aim is to simplify the boilerplate of manually parsing the data and assigning values to an object. It's even more difficult when it comes to using it with CoreData because of the insert or update. And I do not mention performances involved. WAMapping solves this for you!

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
@property (nonatomic, strong) NSArray *chiefs;

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
I'm providing three stores on this repo:

- `WAMemoryStore` which relies on a simple `NSMutableSet`,
- `WANSCodingStore` which saves your objects using `NSCoding` protocol,
- `WACoreDataStore` which makes use of `CoreData`.

You can easily create your own store is you want to use SQLite for example, go checkout the wiki.

```objc
WAMemoryStore *store = [[WAMemoryStore alloc] init];

// or
// WACoreDataStore *store = [[WACoreDataStore alloc] initWithManagedObjectContext:localContext];

// or
// WANSCodingStore *store = [[WANSCodingStore alloc] initWithArchivePath:archivePath];
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

# Default mappings
If you have a server which returns all dates within the same format, then you can ask the mapper or the reverse mapper once to transform the value.

Instead of writing

```objc
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
```

You would write

```objc
[enterpriseMapping addAttributeMappingsFromDictionary:@{
                                                        @"id": @"itemID",
                                                        @"name": @"name",
                                                        @"address.street_number": @"streetNumber",
                                                        @"creation_date": @"creationDate"
                                                        }];


id(^toDateMappingBlock)(id ) = ^id(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        return [dateFormatter dateFromString:value];
    }
    
    return value;
};

[mapper addDefaultMappingBlock:toDateMappingBlock
           forDestinationClass:[NSDate class]];
```

The same thing happens to the reverse mapper. Note that if you provide a custom mapping on an `NSDate` object for a specific property (like a date with only the year), you can add the property to the entity mapping which will override the default behavior for this specific property.

# Progress and cancellation
Both `WAMapper` and `WAReverseMapper` support `NSProgress`. Note that Apple explicitely says in their documentation about `NSProgressReporting` (which we are mimicing here) `Objects that adopt this protocol should typically be "one-shot"` which means you should use one `WAMapper` per map operation.

## Progress
You can track the progress using this little piece of code. Note that the progress counts the main top objects mapped (if your array contains one object with a thousand objects as relationship, the progress will not reflect the thousand subobjects mapped). This is per choice because adopting child progress prior to iOS 9 is not great.

```objc
[mapper.progress addObserver:self
                  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                     options:NSKeyValueObservingOptionNew
                     context:NULL];
```

```objc
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))] && [object isKindOfClass:[NSProgress class]]) {
        NSLog(@"Mapping progress = %f", [change[@"new"] doubleValue]);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
```

## Cancellation
You can cancel the mapping or the reverse mapping using this piece of code. Note that for cancellation to happen, you have to call the mapping from an other thread!

```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [mapper mapFromRepresentation:JSON mapping:employeeMapping completion:^(NSArray *mappedObjects, NSError *error) {
        NSLog(@"Mapped objects %@ - Error %@", mappedObjects, error);
    }];
});

[mapper.progress cancel];
```

# Side notes
## TODOs

- [ ] Benchmark against popular mappers
- [ ] Add more tests for keypath handling, especially on relationship

## Inspiration
You'll find inspiration from [Restkit](https://github.com/RestKit/RestKit) and [FastEasyMapping](https://github.com/Yalantis/FastEasyMapping). These are both libraries I used on projects but with issues

#Contributing : Problems, Suggestions, Pull Requests?

Please open a new Issue [here](https://github.com/Wasappli/WAMapping/issues) if you run into a problem specific to WAAppRouting.

For new features pull requests are encouraged and greatly appreciated! Please try to maintain consistency with the existing code style. If you're considering taking on significant changes or additions to the project, please ask me before by opening a new Issue to have a chance for a merge.

#That's all folks !

- If your are happy don't hesitate to send me a tweet [@ipodishima](http://twitter.com/ipodishima)!
- Distributed under MIT licence.
- Follow Wasappli on [facebook](https://www.facebook.com/wasappli)
