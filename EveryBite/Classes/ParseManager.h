//
//  ParseManager.h
//  EatHue
//
//  Created by Russell on 01/15/15.
//  Copyright (c) 2014 Russell Research Corporation. All rights reserved.
//r
//------------------------------------------------------------------------------

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface ParseManager : NSObject

#define kSettingsClass  @"Settings"
#define kImageClass     @"Image"

#define kImages         @"images"

#define kUser           @"user"
#define kImage          @"image"
#define kObjectId       @"objectId"
#define kHistogram      @"histogram"
#define kCreatedAt      @"createdAt"

#define kEmail          @"email"
#define kPassword       @"password"

+ (ParseManager *)sharedInstance;
+ (void)getImagesForDay:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block;
+ (void)getImagesForMonth:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block;
+ (void)signupWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block;
+ (void)uploadImage:(UIImage *)image histogram:(NSMutableArray *)histogram block:(void (^)( PFObject *pfObject ))block;

@end
