//
//  UIImage+Util.m
//  EveryBite
//
//  Created by Yanxian Liu on 10/11/16.
//  Copyright © 2016 Russell Research Corporation. All rights reserved.
//

#import "UIImage+Util.h"

@implementation UIImage (Util)

//----------------------------------------------------------------------------------
+(UIImage*)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point
//----------------------------------------------------------------------------------
{
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    UIColor *textColor = [UIColor whiteColor];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y + point.x, image.size.width - point.x, image.size.height);
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font};
    
    [[UIColor brownColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(0, point.y, image.size.width, image.size.height - point.y));
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
