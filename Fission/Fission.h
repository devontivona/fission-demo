//
//  Fission.h
//  Fission
//
//  Created by Devon Tivona on 3/10/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fission : NSObject

+ (Fission *)sharedInstanceWithToken:(NSString *)token;
+ (Fission *)sharedInstance;

- (void)runExperiment:(NSString *)experimentName withVariations:(NSArray *)variations handler:(void (^)(NSString *variation))handler;
- (void)trackEvent:(NSString *)event;

@end
