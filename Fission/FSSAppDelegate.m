//
//  FSSAppDelegate.m
//  Fission
//
//  Created by Devon Tivona on 3/3/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import "FSSAppDelegate.h"
#import "FSSViewController.h"

@implementation FSSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Fission *fission = [Fission sharedInstanceWithToken:@"2309bca6e91f877b8dfa5972bd715a52"];
    
    FSSViewController *viewController = [[FSSViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    [fission runExperiment:@"Background Color" withVariations:@[@"Blue", @"Red", @"Green"] handler:^(NSString *variation) {
        NSLog(@"Running experiment with variation: %@", variation);
        if ([variation isEqualToString:@"Blue"]) {
            viewController.view.backgroundColor = [UIColor blueColor];
        } else if ([variation isEqualToString:@"Red"]) {
            viewController.view.backgroundColor = [UIColor redColor];
        } else if ([variation isEqualToString:@"Green"]) {
            viewController.view.backgroundColor = [UIColor greenColor];
        }
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
