//
//  ViewController.m
//  EatHue
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
