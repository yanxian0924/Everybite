//
//  ProfileViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 2/17/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "ParseManager.h"
#import "UIFont+ClientFont.h"
#import "UIColor+ClientColor.h"
#import "UIImage+ImageEffects.h"
#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];

    self.view.backgroundColor= [UIColor blackColor];
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 20, self.view.frame.size.width, 43 )];
    label.text= @"About EatHue";
    label.textAlignment= NSTextAlignmentCenter;
    label.backgroundColor= [UIColor clientBarColor];
    label.textColor= [UIColor redColor];
    [label setFont:[UIFont clientTitleFont]];
    [self.view addSubview:label];
    
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20+43, self.view.frame.size.width, 1 )];
    view.backgroundColor= [UIColor lightGrayColor];
    [self.view addSubview:view];
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20, 44, 43 )];
        view.backgroundColor= [UIColor clearColor];
        [self.view addSubview:view];
        
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake( 44/2-12/2, 44/2-20/2, 12, 20 )];
        imageView.image= [UIImage imageNamed:@"chevronLeft" withColor:[UIColor redColor]];
        [view addSubview:imageView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( backButtonPressed )];
        [view addGestureRecognizer:tapGestureRecognizer];
    }
    
    float y= self.view.frame.size.height-44-1;
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, y, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor lightGrayColor];
        [self.view addSubview:view];
    }
    
    y+= 1;
    
    UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    button.frame= CGRectMake( self.view.frame.size.width/3, y, self.view.frame.size.width/3, 44 );
    [button addTarget:self action:@selector( logoutButtonPressed ) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Logout" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont clientTitleFont]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
}

//------------------------------------------------------------------------------
- (void)logoutButtonPressed
//------------------------------------------------------------------------------
{
    [PFUser logOut];

    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kEmail];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kPassword];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
- (void)backButtonPressed
//------------------------------------------------------------------------------
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
