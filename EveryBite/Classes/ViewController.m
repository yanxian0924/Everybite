//
//  ViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 1/10/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "ViewController.h"
#import "RootViewController.h"

@interface ViewController () <UIGestureRecognizerDelegate> {
    
    UINavigationController *mNavigationController;
    
}

@end

@implementation ViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    self.view.backgroundColor= [UIColor blackColor];
    
    RootViewController *rootViewController= [[RootViewController alloc] init];
    rootViewController.view.backgroundColor= [UIColor blackColor];
    
    mNavigationController= [[UINavigationController alloc] initWithRootViewController:rootViewController];
    mNavigationController.navigationBarHidden= YES;
    mNavigationController.interactivePopGestureRecognizer.delegate = self;
    [self.view addSubview:mNavigationController.view];
}

@end
