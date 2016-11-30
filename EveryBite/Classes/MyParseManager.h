//
//  ParseManager.h
//  EatHue
//
//------------------------------------------------------------------------------

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface MyParseManager : NSObject

#define kSettingsClass  @"Settings"
#define kImageClass     @"Image"

#define kImages         @"images"

#define kUser           @"user"
#define kImage          @"image"
#define kObjectId       @"objectId"
#define kHistogram      @"histogram"
#define kCaption        @"caption"
#define kCreatedAt      @"createdAt"

#define kEmail          @"email"
#define kPassword       @"password"

+ (MyParseManager *)sharedInstance;
+ (void)getImagesForDay:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block;
+ (void)getImagesForMonth:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block;
+ (void)signupWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block;
+ (void)uploadImage:(UIImage *)image histogram:(NSMutableArray *)histogram caption:(NSString *)caption block:(void (^)( PFObject *pfObject ))block;

@end
