//
//  AppDelegate.h
//  EveryBite
//
//  Created by Russell Mitchell on 9/29/15.
//  Copyright © 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property( strong, nonatomic ) NSString *mGuestUserEmail;

@property( strong, nonatomic ) NSString *mGuestUserPassword;

+ (AppDelegate *)sharedInstance;

@end

