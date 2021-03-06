//
//  AppDelegate.m
//  EatHue
//
//------------------------------------------------------------------------------

#import <Parse/Parse.h>

#import "ImageCache.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#define kGuestEmail     @"guestEmail"
#define kGuestPassword  @"guestPassword"

//------------------------------------------------------------------------------
+ (AppDelegate *)sharedInstance
//------------------------------------------------------------------------------
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//------------------------------------------------------------------------------
{
//    [Parse setApplicationId:@"Qe3iCWbdAd0ShHIQOyVDdCIz4rmldHTxaFxhfv3V" clientKey:@"OkGhEpgZCutfQg6LWt9Yu0NXbnHl6AZcWvuNPdys"];  // Russell
    
//    [Parse setApplicationId:@"MRz149Z0FzbG01OuxhdKJhkdK5KenSXCuJkrh0NR" clientKey:@"FUyp0cs4zAaJDxPw0dbmAaaqsEkAnGwuZAriJv5z"]; // Edison

    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"MRz149Z0FzbG01OuxhdKJhkdK5KenSXCuJkrh0NR";
        configuration.clientKey = @"FUyp0cs4zAaJDxPw0dbmAaaqsEkAnGwuZAriJv5z";
        configuration.server = @"http://parseserver-3uziz-env.us-east-1.elasticbeanstalk.com/parse";
    }]];
    
    self.mGuestUserPassword= kGuestPassword;

    // create an ImageCache shared object
    
    [ImageCache sharedInstance];

    if (![[NSUserDefaults standardUserDefaults] valueForKey:kGuestEmail]) {
        
        CFUUIDRef uuid= CFUUIDCreate( kCFAllocatorDefault );
        NSString *uuidStr= (__bridge_transfer NSString *)CFUUIDCreateString( kCFAllocatorDefault, uuid );
        
        CFRelease(uuid);

        self.mGuestUserEmail= [NSString stringWithFormat:@"Guest.%@@gmail.com", uuidStr];
        
        [[NSUserDefaults standardUserDefaults] setValue:self.mGuestUserEmail forKey:kGuestEmail];
        [[NSUserDefaults standardUserDefaults] synchronize];

    } else {

        self.mGuestUserEmail= [[NSUserDefaults standardUserDefaults] valueForKey:kGuestEmail];

    }

    // hack to prevent the 3-4 sec delay when loading the initial keyboard
    
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];

    return YES;
}

@end
