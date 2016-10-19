//
//  UIImage+Util.h
//  EveryBite
//
//  Created by Yanxian Liu on 10/11/16.
//  Copyright © 2016 Russell Research Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+(UIImage*)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point;

@end
