//
//  NSArray+Map.h
//  Fission
//
//  Created by Devon Tivona on 3/17/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^MapBlock)(id);

@interface NSArray (Map)
- (NSArray *)map:(MapBlock)block;
@end