//
//  UIImage+ImageEffects.h
//  Connexin
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)colorImage:(UIImage *)img withColor:(UIColor *)color;
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

@end
