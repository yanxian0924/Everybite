//
//  SignupViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 1/21/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "ActivityView.h"
#import "ParseManager.h"
#import "UIFont+ClientFont.h"
#import "LiveViewController.h"
#import "UIColor+ClientColor.h"
#import "SignupViewController.h"

@interface SignupViewController () <UITextFieldDelegate> {
    
    UITextField *mEmailTextField;
    UITextField *mEmailTextField2;
    UITextField *mPasswordTextField;
    
}

@end

@implementation SignupViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    self.view.backgroundColor= [UIColor blackColor];
    
    // top bar label
    
    {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 20, self.view.frame.size.width, 44 )];
        label.backgroundColor= [UIColor clearColor];
        label.textAlignment= NSTextAlignmentCenter;
        label.text= @"Sign up";
        label.font= [UIFont clientTitleFont];
        label.textColor= [UIColor lightGrayColor];
        [self.view addSubview:label];
        
        // separator
        
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20+44-1, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor lightGrayColor];
        [self.view addSubview:view];
    }
    
    float y= 20+44+44;
    
    // email address
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 10, y, self.view.frame.size.width-20, 44 )];
        view.layer.borderColor= [[UIColor lightGrayColor] CGColor];
        view.layer.borderWidth= 1;
        [self.view addSubview:view];
        
        mEmailTextField= [[UITextField alloc] initWithFrame:CGRectMake( 10, 0, view.frame.size.width-20, 44 )];
        mEmailTextField.attributedPlaceholder= [[NSAttributedString alloc] initWithString:@"Enter your email address" attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor}];
        mEmailTextField.font= [UIFont clientBodyFont];
        mEmailTextField.textColor= [UIColor lightGrayColor];
        mEmailTextField.returnKeyType= UIReturnKeyDone;
        mEmailTextField.delegate= self;
        mEmailTextField.autocapitalizationType= UITextAutocapitalizationTypeNone;
        [view addSubview:mEmailTextField];
    }
    
    y+= 44+10;

    // re-enter email address
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 10, y, self.view.frame.size.width-20, 44 )];
        view.layer.borderColor= [[UIColor lightGrayColor] CGColor];
        view.layer.borderWidth= 1;
        [self.view addSubview:view];
        
        mEmailTextField2= [[UITextField alloc] initWithFrame:CGRectMake( 10, 0, view.frame.size.width-20, 44 )];
        mEmailTextField2.attributedPlaceholder= [[NSAttributedString alloc] initWithString:@"Re-Enter your email address" attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor}];
        mEmailTextField2.font= [UIFont clientBodyFont];
        mEmailTextField2.textColor= [UIColor lightGrayColor];
        mEmailTextField2.returnKeyType= UIReturnKeyDone;
        mEmailTextField2.delegate= self;
        mEmailTextField2.autocapitalizationType= UITextAutocapitalizationTypeNone;
        [view addSubview:mEmailTextField2];
    }
    
    y+= 44+10;
    
    // password
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 10, y, self.view.frame.size.width-20, 44 )];
        view.layer.borderColor= [[UIColor lightGrayColor] CGColor];
        view.layer.borderWidth= 1;
        [self.view addSubview:view];
        
        mPasswordTextField= [[UITextField alloc] initWithFrame:CGRectMake( 10, 0, view.frame.size.width-20, 44 )];
        mPasswordTextField.attributedPlaceholder= [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor}];
        mPasswordTextField.secureTextEntry= YES;
        mPasswordTextField.font= [UIFont clientBodyFont];
        mPasswordTextField.textColor= [UIColor lightGrayColor];
        mPasswordTextField.returnKeyType= UIReturnKeyDone;
        mPasswordTextField.delegate= self;
        [view addSubview:mPasswordTextField];
    }
    
    // signup button
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, self.view.frame.size.height-44, self.view.frame.size.width, 44 );
        [button setBackgroundColor:[UIColor blackColor]];
        [button setTitle:@"Sign up" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( signupButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//------------------------------------------------------------------------------
{
    [textField resignFirstResponder];
    
    return YES;
}

//------------------------------------------------------------------------------
- (void)signupButtonPressed
//------------------------------------------------------------------------------
{
    if (![mEmailTextField.text length]) {
        
        NSString *msg= [NSString stringWithFormat:@"\nPlease enter your email address"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
        
    } else if (![mEmailTextField2.text length]) {

        NSString *msg= [NSString stringWithFormat:@"\nPlease re-enter your email address"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
        
    } else if (![mPasswordTextField.text length]) {
        
        NSString *msg= [NSString stringWithFormat:@"\nPlease enter your password"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
        
    } else if (![mEmailTextField.text isEqualToString:mEmailTextField2.text]) {

        NSString *msg= [NSString stringWithFormat:@"\nYour email addresses do not match"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
        
    }
    
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:activityView];
    
    [ParseManager signupWithEmail:[mEmailTextField.text lowercaseString] password:mPasswordTextField.text block:^( NSError *error ) {
        
        [activityView removeFromSuperview];
        
        if (!error) {
            
            [[NSUserDefaults standardUserDefaults] setValue:[mEmailTextField.text lowercaseString] forKey:kEmail];
            [[NSUserDefaults standardUserDefaults] setValue:mPasswordTextField.text forKey:kPassword];
            
            LiveViewController *liveViewController= [[LiveViewController alloc] init];
            [self.navigationController pushViewController:liveViewController animated:YES];
            
        } else {
            
            NSString *msg= [NSString stringWithFormat:@"\n%@", error.userInfo[@"error"]];
            
            UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            
        }
    }];
}

@end
