//
//  UIFont+Connexin.m
//  Connexin
//
//  Created by Russell Mitchell on 1/17/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
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
