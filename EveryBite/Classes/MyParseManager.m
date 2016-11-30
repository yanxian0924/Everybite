//
//  ParseManager.m
//  EatHue
//
//------------------------------------------------------------------------------

#import <MediaPlayer/MediaPlayer.h>

#import "ImageCache.h"
#import "MyParseManager.h"

@implementation MyParseManager

static MyParseManager *instance;

//------------------------------------------------------------------------------
+ (MyParseManager *)sharedInstance
//------------------------------------------------------------------------------
{
    @synchronized( self ) {
        
        if (instance == nil) {
            
            instance = [[self alloc] init];
            
        }
    }
    
    return instance;
}

//------------------------------------------------------------------------------
+ (void)signupWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block
//------------------------------------------------------------------------------
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        PFUser *user = [PFUser user];
        
        user.email = email;
        user.username = email;
        user.password = password;
        
        NSError *error;

        [user signUp:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( error );
        });
    });
}

//------------------------------------------------------------------------------
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password block:(void (^)( NSError *error ))block
//------------------------------------------------------------------------------
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        NSError *error;
        
        [PFUser logInWithUsername:email password:password error:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            block( error );
        });
    });
}

//------------------------------------------------------------------------------
+ (void)uploadImage:(UIImage *)image histogram:(NSMutableArray *)histogram caption:(NSString *)caption block:(void (^)( PFObject *pfObject ))block
//------------------------------------------------------------------------------
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        PFObject *pfObject= [PFObject objectWithClassName:kImageClass];
        
        pfObject.ACL= [PFACL ACLWithUser:[PFUser currentUser]];
        [pfObject.ACL setPublicReadAccess:YES];
        [pfObject.ACL setPublicWriteAccess:YES];
        
        pfObject[kUser]= [PFUser currentUser];
        pfObject[kHistogram]= histogram;
        if ([caption length]) {
            pfObject[kCaption] = caption;
        }
        
        NSData *data= UIImagePNGRepresentation( image );
        
        PFFile *file = [PFFile fileWithName:@"image.png" data:data];
        
        NSError *error= nil;
        
        [file save:&error];
        
        if (!error) {
            
            pfObject[kImage]= file;
            
            [pfObject save:&error];

            if (!error) {
                
                [ImageCache saveImageNamed:pfObject.objectId withData:data];
                
            }
        }
        
        if (block) {
            dispatch_async( dispatch_get_main_queue(), ^{
                (error)?block( nil ):block( pfObject );
            });            
        }
    });
}

//------------------------------------------------------------------------------
+ (void)getImagesForDay:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block
//------------------------------------------------------------------------------
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        PFQuery *userQuery= [PFUser query];
        [userQuery whereKey:kObjectId equalTo:[PFUser currentUser].objectId];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate= [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:NSCalendarMatchStrictly];
        NSDate *endDate= [calendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:NSCalendarMatchStrictly];
        
        PFQuery *query= [PFQuery queryWithClassName:kImageClass];
        [query orderByAscending:@"createdAt"];
        [query whereKey:kCreatedAt greaterThan:startDate];
        [query whereKey:kCreatedAt lessThan:endDate];
        [query whereKey:kUser matchesQuery:userQuery];
        
        NSArray *pfObjects= [query findObjects];
        
        for (PFObject *pfObject in pfObjects) {
  
            if (![ImageCache imageIsCached:pfObject.objectId]) {
                
                PFFile *file = pfObject[kImage];
                
                [ImageCache saveImageNamed:pfObject.objectId withData:[file getData]];
                
            }
        }
        
        if (block) {
            dispatch_async( dispatch_get_main_queue(), ^{
                block( pfObjects );
            });
        }
    });
}

//------------------------------------------------------------------------------
+ (void)getImagesForMonth:(NSDate *)date block:(void (^)( NSArray *pfObjects ))block
//------------------------------------------------------------------------------
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        [dateComponents setDay:1];
        [dateComponents setHour:0];
        NSDate *startDate= [[NSCalendar currentCalendar] dateFromComponents:dateComponents];

        NSInteger monthLength= [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
        [dateComponents setHour:23];
        [dateComponents setMinute:59];
        [dateComponents setSecond:59];
        [dateComponents setDay:monthLength];
        NSDate *endDate= [[NSCalendar currentCalendar] dateFromComponents:dateComponents];

        PFQuery *userQuery= [PFUser query];
        [userQuery whereKey:kObjectId equalTo:[PFUser currentUser].objectId];
                
        PFQuery *query= [PFQuery queryWithClassName:kImageClass];
        [query orderByAscending:@"createdAt"];
        [query whereKey:kCreatedAt greaterThanOrEqualTo:startDate];
        [query whereKey:kCreatedAt lessThanOrEqualTo:endDate];
        [query whereKey:kUser matchesQuery:userQuery];
        
        NSArray *pfObjects= [query findObjects];
        
        for (PFObject *pfObject in pfObjects) {
            
            if (![ImageCache imageIsCached:pfObject.objectId]) {
                
                PFFile *file = pfObject[kImage];
                
                [ImageCache saveImageNamed:pfObject.objectId withData:[file getData]];
                
            }
        }
        
        if (block) {
            dispatch_async( dispatch_get_main_queue(), ^{
                block( pfObjects );
            });
        }
    });
}

@end
