//
//  WAMappingMacros.h
//  WAMapping
//
//  Created by Marian Paul on 01/02/2016.
//  Copyright © 2016 Wasappli. All rights reserved.
//

#ifndef WAMappingMacros_h
#define WAMappingMacros_h

#define WAMAssert(cond, desc, ...) NSAssert(cond, desc, ##__VA_ARGS__)

#define WAMParameterAssert(obj) NSParameterAssert(obj)
#define WAMClassParameterAssert(obj, className) WAMParameterAssert([obj isKindOfClass:[className class]])
#define WAMClassParameterAssertIfExists(obj, className) if (obj) { WAMParameterAssert([obj isKindOfClass:[className class]]);}
#define WAMProtocolParameterAssertIfExists(obj, protocolName) if (obj) { WAMParameterAssert([obj conformsToProtocol:@protocol(protocolName)]);}
#define WAMProtocolParameterAssert(obj, protocolName) WAMParameterAssert([obj conformsToProtocol:@protocol(protocolName)]);
#define WAMProtocolClassAssert(class, protocolName) WAMParameterAssert([class conformsToProtocol:@protocol(protocolName)]);

#define WAM_CONTINUE_IF_NULL(obj) if ([obj isEqual:[NSNull null]]) {continue;}
#define WAM_CONTINUE_IF_NIL(obj) if (!obj) {continue;}
#define WAM_OBJ_TO_NIL_IF_NULL(obj) (obj = ([obj isEqual:[NSNull null]]) ? nil : obj)

#endif /* WAMappingMacros_h */
