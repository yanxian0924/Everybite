//
//  UIImage+ImageEffects.m
//  Connexin
//
//  Created by Russell Mitchell on 1/29/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "UIImage+ImageEffects.h"

@implementation UIImage (ImageEffects)

//------------------------------------------------------------------------------
+ (UIImage *)colorImage:(UIImage *)img withColor:(UIColor *)color
//------------------------------------------------------------------------------
{
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

//------------------------------------------------------------------------------
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
//------------------------------------------------------------------------------
{
    UIImage *img = [UIImage imageNamed:name];
    if (!img)
        return nil;
    
    UIImage* coloredImg = [self colorImage:img withColor:color];
    
    //return the color-burned image
    return coloredImg;
    
}

//------------------------------------------------------------------------------
+ (UIImage *)imageWithColor:(UIColor *)color
//------------------------------------------------------------------------------
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
