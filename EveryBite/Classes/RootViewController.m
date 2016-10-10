//
//  LoginViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 1/11/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "AppDelegate.h"
#import "ActivityView.h"
#import "ParseManager.h"
#import "UIFont+ClientFont.h"
#import "LiveViewController.h"
#import "RootViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"

@interface RootViewController () {
    
    float mActivityCenterY;
    
}

@end

@implementation RootViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];

    float width= self.view.frame.size.width - 40;
    float y= self.view.frame.size.height - 20 - 44 - 44 - 44;
    
    UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake( 20, y/2-width/2, width, width )];
    [imageView setImage:[UIImage imageNamed:@"produce-pie"]];
    [self.view addSubview:imageView];
    
    mActivityCenterY= imageView.frame.origin.y + imageView.frame.size.height/2;
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, y, self.view.frame.size.width, 44 );
        [button setTitle:@"Login" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( loginButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    y+= 44;
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, y, self.view.frame.size.width, 44 );
        [button setTitle:@"Signup" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( signupButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    y+= 44;
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, y, self.view.frame.size.width, 44 );
        [button setTitle:@"Continue as Guest" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( continueButtonPressed: ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    
    NSString *email= [[NSUserDefaults standardUserDefaults] valueForKey:kEmail];
    NSString *password= [[NSUserDefaults standardUserDefaults] valueForKey:kPassword];

    if (([email length])&&([password length])) {
        
        ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds centerY:mActivityCenterY];
        [self.view addSubview:activityView];
        
        [ParseManager loginWithEmail:email password:password block:^( NSError *error ) {
            
            if ([PFUser currentUser]) {
                
                [activityView removeFromSuperview];
                
                LiveViewController *liveViewController= [[LiveViewController alloc] init];
                [self.navigationController pushViewController:liveViewController animated:YES];
                
            }
        }];
    }
}

//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser]) {
        [PFUser logOut];
    }
}

//------------------------------------------------------------------------------
- (void)loginButtonPressed
//------------------------------------------------------------------------------
{
    LoginViewController *loginViewController= [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

//------------------------------------------------------------------------------
- (void)signupButtonPressed
//------------------------------------------------------------------------------
{
    SignupViewController *signupViewController= [[SignupViewController alloc] init];
    [self.navigationController pushViewController:signupViewController animated:YES];
}

//------------------------------------------------------------------------------
- (void)continueButtonPressed:(UIButton *)button
//------------------------------------------------------------------------------
{
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds centerY:mActivityCenterY];
    [self.view addSubview:activityView];

    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [ParseManager loginWithEmail:[AppDelegate sharedInstance].mGuestUserEmail password:[AppDelegate sharedInstance].mGuestUserPassword block:^( NSError *error ) {

        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if ([PFUser currentUser]) {
            
            [activityView removeFromSuperview];
            
            LiveViewController *liveViewController= [[LiveViewController alloc] init];
            [self.navigationController pushViewController:liveViewController animated:YES];
            
        } else {
            
            [ParseManager signupWithEmail:[AppDelegate sharedInstance].mGuestUserEmail password:[AppDelegate sharedInstance].mGuestUserPassword block:^( NSError *error ) {
                
                [activityView removeFromSuperview];

                if ([PFUser currentUser]) {
                    
                    LiveViewController *liveViewController= [[LiveViewController alloc] init];
                    [self.navigationController pushViewController:liveViewController animated:YES];
                    
                } else {
                    
                    NSString *message= (error)?[error localizedDescription]:@"Request timed out.";
                    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alertView show];
                    
                }
            }];
        }
    }];
}

@end
