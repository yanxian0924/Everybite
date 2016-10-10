//
//  DayTableView.h
//  EatHue
//
//  Created by Russell Mitchell on 1/16/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface DayTableView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

@property( nonatomic, strong ) NSDate *mDate;

@end
