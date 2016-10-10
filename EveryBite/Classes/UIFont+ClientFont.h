//
//  UIFont+Connexin.h
//  Connexin
//
//  Created by Russell Mitchell on 1/17/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface UIFont (ClientFont)

+ (UIFont *)clientBodyFont;
+ (UIFont *)clientTitleFont;
+ (UIFont *)clientFontWithSize:(NSInteger)size;

@end
