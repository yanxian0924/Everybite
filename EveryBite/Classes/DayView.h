//
//  DayView.h
//  EatHue
//
//  Created by Russell Mitchell on 1/13/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface DayView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

- (void)reinitWithDate:(NSDate *)date;

@end
