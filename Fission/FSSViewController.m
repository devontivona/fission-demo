//
//  FSSViewController.m
//  Fission
//
//  Created by Devon Tivona on 3/3/14.
//  Copyright (c) 2014 Devon Tivona. All rights reserved.
//

#import "FSSViewController.h"

@interface FSSViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation FSSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Fission";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setTitle:@"Hello World" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view.left).offset(20.0);
        make.right.equalTo(self.view.right).offset(-20.0);
        make.height.equalTo(@44);
    }];
    
    Fission *fission = [Fission sharedInstance];
    [fission runExperiment:@"Button Color" withVariations:@[@"Blue", @"Red", @"Green"] handler:^(NSString *variation) {
        NSLog(@"Running experiment with variation: %@", variation);
        if ([variation isEqualToString:@"Blue"]) {
            self.button.backgroundColor = [UIColor blueColor];
        } else if ([variation isEqualToString:@"Red"]) {
            self.button.backgroundColor = [UIColor redColor];
        } else if ([variation isEqualToString:@"Green"]) {
            self.button.backgroundColor = [UIColor greenColor];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
