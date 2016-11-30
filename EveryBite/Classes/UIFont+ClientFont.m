//
//  UIFont+Connexin.m
//  Connexin
//
//------------------------------------------------------------------------------

#import "UIFont+ClientFont.h"

@implementation UIFont (Connexin)

//------------------------------------------------------------------------------
+ (UIFont *)clientTitleFont
//------------------------------------------------------------------------------
{
    return [UIFont fontWithName:@"Avenir-Light" size:24];
}

//------------------------------------------------------------------------------
+ (UIFont *)clientBodyFont
//------------------------------------------------------------------------------
{
    return [UIFont fontWithName:@"Avenir-Light" size:16];
}

//------------------------------------------------------------------------------
+ (UIFont *)clientFontWithSize:(NSInteger)size
//------------------------------------------------------------------------------
{
    return [UIFont fontWithName:@"Avenir-Light" size:size];
}

@end
