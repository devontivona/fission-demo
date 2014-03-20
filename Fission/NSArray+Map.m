//
//  NSArray+Map.m
//  Fission
//
//  Created by Devon Tivona on 3/17/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)map:(MapBlock)block
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        [resultArray addObject:block(object)];
    }
    return resultArray;
}

@end