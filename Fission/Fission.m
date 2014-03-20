//
//  Fission.m
//  Fission
//
//  Created by Devon Tivona on 3/10/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AFNetworking/AFNetworking.h>

#import "TargetConditionals.h"
#import "NSArray+Map.h"
#import "Fission.h"

#define VERSION @"0.1.0"

NSString * const FSSExperimentsDictionaryUserDefaultsKey = @"FSSExperimentsDictionaryUserDefaultsKey";

@interface Fission ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSDictionary *properties;
@property (nonatomic, strong) NSDictionary *experiments;

@end

@implementation Fission

static Fission *sharedInstance = nil;

+ (Fission *)sharedInstanceWithToken:(NSString *)token
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithToken:token];
    });
    return sharedInstance;
}

+ (Fission *)sharedInstance
{
    if (sharedInstance == nil) {
        NSLog(@"%@ warning sharedInstance called before sharedInstanceWithToken:", self);
    }
    return sharedInstance;
}

- (instancetype)initWithToken:(NSString *)token
{
    if (token == nil) {
        token = @"";
    }
    if ([token length] == 0) {
        NSLog(@"%@ warning empty token", self);
    }
    if (self = [self init]) {
        self.token = token;
        self.serverURL = @"http://fission-demo.herokuapp.com";
        NSMutableDictionary *properties = [self collectSystemProperties];
        [properties addEntriesFromDictionary:@{ @"app" : @{ @"token" : self.token }}];
        [self loadExperiments];
        [self updateClientWithProperties:properties completion:^(BOOL success) {
            [self updateExperiments];
        }];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Fission: %p %@>", self, self.token];
}

- (NSString *)clientToken
{
#if TARGET_IPHONE_SIMULATOR
    return @"Simulator";
#else
    UIDevice *device = [UIDevice currentDevice];
    return [[device identifierForVendor] UUIDString];
#endif
}

- (NSMutableDictionary *)collectSystemProperties
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];

    [properties setValue:[self clientToken] forKey:@"token"];
    [properties setValue:@"iOS" forKey:@"library"];
    [properties setValue:VERSION forKey:@"version"];
    // [properties setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] forKey:@"app_version"];
    // [properties setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"app_release"];
    [properties setValue:@"Apple" forKey:@"manufacturer"];

    UIDevice *device = [UIDevice currentDevice];
    [properties setValue:[device systemName] forKey:@"os"];
    [properties setValue:[device systemVersion] forKey:@"os_version"];
    [properties setValue:[device model] forKey:@"model"];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if (carrier.carrierName.length) {
        [properties setValue:carrier.carrierName forKey:@"carrier"];
    }
    return properties;
}

- (void)runExperiment:(NSString *)experimentName withVariations:(NSArray *)variations handler:(void (^)(NSString *variation))handler
{
    NSString *variation = [self.experiments valueForKey:experimentName];
    if (variation == nil) {
        variation = [variations objectAtIndex:0];
    }
    handler(variation);
    [self updateExperimentWithName:experimentName variations:variations];
    [self updateExperiments];
}

- (void)trackEvent:(NSString *)event
{
    
}

#pragma mark - Persistence

- (void)persistExperiments
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.experiments forKey:FSSExperimentsDictionaryUserDefaultsKey];
}

- (void)loadExperiments
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *experiments =  [userDefaults objectForKey:FSSExperimentsDictionaryUserDefaultsKey];
    self.experiments = experiments;
}

#pragma mark - Networking

- (AFHTTPRequestOperationManager *)requestOperationManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:self.token forHTTPHeaderField:@"Access-Token"];
    [manager.requestSerializer setValue:[self clientToken] forHTTPHeaderField:@"Client-Token"];
    return manager;
}

- (void)updateClientWithProperties:(NSDictionary *)properties completion:(void (^)(BOOL success))completion
{
    AFHTTPRequestOperationManager *manager = [self requestOperationManager];
    NSDictionary *parameters = @{ @"client" : properties };
    NSString *URL = [NSString stringWithFormat:@"%@/clients.json", self.serverURL];
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(NO);
    }];
}

- (void)updateExperimentWithName:(NSString *)name variations:(NSArray *)variations
{
    AFHTTPRequestOperationManager *manager = [self requestOperationManager];
    NSArray *variationsAttributes = [variations map:^id(NSString *variation) {
        return @{ @"name" : variation };
    }];

    NSDictionary *parameters = @{ @"experiment" : @{ @"name" : name, @"variations_attributes" : variationsAttributes } };
    NSString *URL = [NSString stringWithFormat:@"%@/experiments.json", self.serverURL];
    [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)updateExperiments
{
    AFHTTPRequestOperationManager *manager = [self requestOperationManager];
    NSString *URL = [NSString stringWithFormat:@"%@/experiments.json", self.serverURL];
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSMutableDictionary *experiments = [[NSMutableDictionary alloc] init];
        for (NSDictionary *experiment in responseObject) {
            [experiments setValue:experiment[@"variation"] forKey:experiment[@"name"]];
        }
        self.experiments = experiments;
        [self persistExperiments];
        NSLog(@"Experiments: %@", self.experiments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
