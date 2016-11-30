//
//  AppDelegate.h
//  EveryBite
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property( strong, nonatomic ) NSString *mGuestUserEmail;

@property( strong, nonatomic ) NSString *mGuestUserPassword;

+ (AppDelegate *)sharedInstance;

@end

