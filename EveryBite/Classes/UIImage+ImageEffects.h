//
//  UIImage+ImageEffects.h
//  Connexin
//
//  Created by Russell Mitchell on 1/29/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)colorImage:(UIImage *)img withColor:(UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

@end
