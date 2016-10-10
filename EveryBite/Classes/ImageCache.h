//
//  ImageCache.h
//
//  Created by Russell on 11/16/12.
//  Copyright (c) 2012 Russell Research Corporation. All rights reserved.
//
//  The ImageCache class provides simple methods for persisting image data
//  based on the age of the image.
//
//  USAGE:
//
//  clearImageCache should be called whenever your app enters the foreground.
//  This will ensure that images older than kImageCacheLifetimeMinutes will
//  be deleted.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ImageCache : UIImage

@property( nonatomic, strong ) NSOperationQueue *mOperationQueue;

+ (id)sharedInstance;
+ (void)deleteImageCache;
+ (BOOL)imageIsCached:(NSString *)imageName;
+ (UIImage *)imageNamed:(NSString *)imageName;
+ (void)clearImageCacheOlderThan:(NSInteger)lifetimeSeconds;
+ (void)saveImageNamed:(NSString *)imageName withData:(NSData *)data;

@end
