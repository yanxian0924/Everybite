//
//  MonthView.m
//  EatHue
//
//  Created by Russell Mitchell on 1/24/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "MonthView.h"
#import "CalendarView.h"
#import "UIFont+ClientFont.h"
#import "UIColor+ClientColor.h"

@interface MonthView () <UIScrollViewDelegate,CalendarViewDelegate> {
    
    UILabel *mYearLabel;
    UIScrollView *mScrollView;
    
}

@end

@implementation MonthView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame date:(NSDate *)date
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;
    
    self.backgroundColor= [UIColor blackColor];
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20, frame.size.width, 64 )];
        view.backgroundColor= UIColor.blackColor;
        [self addSubview:view];
    }

    {
        mYearLabel= [[UILabel alloc] initWithFrame:CGRectMake( 10, 20, frame.size.width-20, 44 )];
        mYearLabel.backgroundColor= [UIColor clearColor];
        mYearLabel.textAlignment= NSTextAlignmentRight;
        mYearLabel.font= [UIFont clientTitleFont];
        mYearLabel.textColor= [UIColor lightGrayColor];
        [self addSubview:mYearLabel];
    }
    
    float width= frame.size.width / 7;
    
    float y= 20+44;
    
    float x= 0;
    
    NSMutableArray *days= [[NSMutableArray alloc] initWithObjects:@"S",@"M",@"T",@"W",@"T",@"F",@"S",nil];
    
    for (NSString *day in days) {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( x, y, width, 20 )];
        label.backgroundColor= [UIColor clearColor];
        label.textAlignment= NSTextAlignmentCenter;
        label.textColor= [UIColor lightGrayColor];
        label.font= [UIFont clientBodyFont];
        label.text= day;
        [self addSubview:label];
        x+= width;
    }

    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20+63, frame.size.width, 1 )];
        view.backgroundColor= [UIColor lightGrayColor];
        [self addSubview:view];
    }
    
    mScrollView= [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 20+64, frame.size.width, kCalendarViewHeight )];
    mScrollView.backgroundColor= [UIColor blackColor];
    mScrollView.pagingEnabled= YES;
    mScrollView.delegate= self;
    [self addSubview:mScrollView];
    
    CalendarView *calendarView= [[CalendarView alloc] initWithFrame:CGRectMake( 0, kCalendarViewHeight, frame.size.width, kCalendarViewHeight ) date:date];
    calendarView.delegate= self;
    [mScrollView addSubview:calendarView];
    
    mScrollView.contentSize= CGSizeMake( frame.size.width, kCalendarViewHeight*2 );
    mScrollView.contentOffset= CGPointMake( 0, kCalendarViewHeight );

    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    calendarView.mYear= [dateComponents year];
    
    mYearLabel.text= [NSString stringWithFormat:@"%ld", (long)calendarView.mYear];
    
    return self;
}

//------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//------------------------------------------------------------------------------
{
    CalendarView *calendarView= nil;
    
    for (UIView *view in mScrollView.subviews) {
        if ([view isKindOfClass:[CalendarView class]]) {
            if (view.frame.origin.y == mScrollView.contentOffset.y) {
                calendarView= (CalendarView *)view;
                mYearLabel.text= [NSString stringWithFormat:@"%ld", (long)calendarView.mYear];
                return;
            }
        }
    }

    if (mScrollView.contentOffset.y<=0) {  // we scrolled up, hit top of scrollview
        
        NSDate *oldDate= nil;
        
        for (UIView *view in mScrollView.subviews) {
            if ([view isKindOfClass:[CalendarView class]]) {
                CalendarView *calView= (CalendarView *)view;
                if (view.frame.origin.y==kCalendarViewHeight)
                    oldDate= calView.mDate;
                view.frame= CGRectMake( view.frame.origin.x, view.frame.origin.y+kCalendarViewHeight, view.frame.size.width, view.frame.size.height );
            }
        }
        
        NSDate *newDate= [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:oldDate options:0];
        
        CalendarView *calendarView= [[CalendarView alloc] initWithFrame:CGRectMake( 0, kCalendarViewHeight, self.frame.size.width, kCalendarViewHeight ) date:newDate];
        calendarView.delegate= self;
        [mScrollView addSubview:calendarView];
        
        mScrollView.contentSize= CGSizeMake( self.frame.size.width, mScrollView.contentSize.height+kCalendarViewHeight );
        mScrollView.contentOffset= CGPointMake( 0, kCalendarViewHeight );
        
        NSDateComponents *newDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:newDate];
        calendarView.mYear= [newDateComponents year];
        
        mYearLabel.text= [NSString stringWithFormat:@"%ld", (long)calendarView.mYear];
        
    } else { // we scrolled down, hit bottom of view
        
        NSDate *oldDate= nil;
        
        for (UIView *view in mScrollView.subviews) {
            if ([view isKindOfClass:[CalendarView class]]) {
                CalendarView *calView= (CalendarView *)view;
                if (view.frame.origin.y+kCalendarViewHeight==mScrollView.contentOffset.y) {
                    oldDate= calView.mDate;
                }
            }
        }
        
        NSDate *newDate= [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:oldDate options:0];
        
        CalendarView *calendarView= [[CalendarView alloc] initWithFrame:CGRectMake( 0, mScrollView.contentOffset.y, self.frame.size.width, kCalendarViewHeight ) date:newDate];
        calendarView.delegate= self;
        [mScrollView addSubview:calendarView];
        
        mScrollView.contentSize= CGSizeMake( self.frame.size.width, mScrollView.contentSize.height+kCalendarViewHeight );
        
        NSDateComponents *newDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:newDate];
        calendarView.mYear= [newDateComponents year];
        
        mYearLabel.text= [NSString stringWithFormat:@"%ld", (long)calendarView.mYear];
        
    }
}

//------------------------------------------------------------------------------
- (void)shouldShowDayViewForDate:(NSDate *)date
//------------------------------------------------------------------------------
{
    [self.delegate shouldShowDayViewForDate:date];
}

@end
