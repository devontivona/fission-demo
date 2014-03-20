# Fission
Fission is a hosted, mobile split testing library for iOS. With Fission, running tests on your application is incredibly simple. Below is an example how to run a test:

    Fission *fission = [Fission sharedInstanceWithToken:@"API_KEY"];
    
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