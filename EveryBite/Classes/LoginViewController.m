//
//  LoginViewController.m
//  EatHue
//
//------------------------------------------------------------------------------

#import "ActivityView.h"
#import "MyParseManager.h"
#import "UIFont+ClientFont.h"
#import "LiveViewController.h"
#import "UIColor+ClientColor.h"
#import "LoginViewController.h"

@interface LoginViewController () <UITextFieldDelegate> {
    
    UITextField *mEmailTextField;
    UITextField *mPasswordTextField;
    
}

@end

@implementation LoginViewController

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
        label.text= @"Log in";
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
        mEmailTextField.font= [UIFont clientBodyFont];
        mEmailTextField.textColor= [UIColor lightGrayColor];
        mEmailTextField.attributedPlaceholder= [[NSAttributedString alloc] initWithString:@"Enter your email address" attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor}];
        mEmailTextField.returnKeyType= UIReturnKeyDone;
        mEmailTextField.delegate= self;
        mEmailTextField.autocapitalizationType= UITextAutocapitalizationTypeNone;
        [view addSubview:mEmailTextField];
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kEmail]) {
            mEmailTextField.text= [[NSUserDefaults standardUserDefaults] valueForKey:kEmail];
        }
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
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kPassword]) {
            mPasswordTextField.text= [[NSUserDefaults standardUserDefaults] valueForKey:kPassword];
        }
    }
    
    y+= 44+10;
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, y, self.view.frame.size.width, 44 );
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitle:@"Forgot your password?" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientBodyFont]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( forgotPasswordButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    
    // login button
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, self.view.frame.size.height-44, self.view.frame.size.width, 44 );
        [button setBackgroundColor:[UIColor blackColor]];
        [button setTitle:@"Log in" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( loginButtonPressed ) forControlEvents:UIControlEventTouchDown];
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
- (void)forgotPasswordButtonPressed
//------------------------------------------------------------------------------
{
    if ([mEmailTextField.text length]) {
        
        [PFUser requestPasswordResetForEmailInBackground:mEmailTextField.text];
        
        NSString *msg= [NSString stringWithFormat:@"\nA password reset link has been sent to:\n\n %@", mEmailTextField.text];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Password Reset" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
    } else {
        
        NSString *msg= @"\nPlease enter your email address";
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
    }
}

//------------------------------------------------------------------------------
- (void)loginButtonPressed
//------------------------------------------------------------------------------
{
    if (![mEmailTextField.text length]) {
        
        NSString *msg= [NSString stringWithFormat:@"\nPlease enter your email address"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
        
    } else if (![mPasswordTextField.text length]) {
        
        NSString *msg= [NSString stringWithFormat:@"\nPlease enter your password"];
        
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Oops!" message:msg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }

    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:activityView];
    
    [MyParseManager loginWithEmail:[mEmailTextField.text lowercaseString] password:mPasswordTextField.text block:^( NSError *error ) {
        
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
