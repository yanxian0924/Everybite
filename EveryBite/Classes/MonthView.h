//
//  MonthView.h
//  EatHue
//
//  Created by Russell Mitchell on 1/24/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@protocol MonthViewDelegate <NSObject>

- (void)shouldShowDayViewForDate:(NSDate *)date;

@end

@interface MonthView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

@property( nonatomic, weak ) id<MonthViewDelegate>delegate;

@end
