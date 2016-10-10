//
//  CalendarView.m
//  EatHue
//
//  Created by Russell Mitchell on 1/24/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "CalendarView.h"
#import "ActivityView.h"
#import "ParseManager.h"
#import "ColorBarView.h"
#import "UIFont+ClientFont.h"
#import "UIColor+ClientColor.h"

@interface CalendarView () {
    
    NSMutableArray *mColorBarViews;
    
}

@end

@implementation CalendarView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame date:(NSDate *)date
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;
    
    self.mDate= date;
    
    mColorBarViews= [[NSMutableArray alloc] init];

    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM"];
        
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, frame.size.width, 44 )];
        label.backgroundColor= [UIColor clearColor];
        label.textAlignment= NSTextAlignmentCenter;
        label.text= [[dateFormatter stringFromDate:date] uppercaseString];
        label.font= [UIFont clientTitleFont];
        label.textColor= [UIColor lightGrayColor];
        [self addSubview:label];
    }
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 44-1, frame.size.width, 1 )];
        view.backgroundColor= [UIColor lightGrayColor];
        [self addSubview:view];
    }
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    [dateComponents setDay:1];
    NSDate *firstDate= [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];

    dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:firstDate];
    NSInteger startDay= dateComponents.weekday - 1;
    
    int day= 1;
    float y= 44;
    float width= frame.size.width / 7;
    float height= width+20;
    float x= startDay * width;

    NSInteger monthLength= [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    NSMutableArray *views= [[NSMutableArray alloc] init];
    [views addObject:[[UIView alloc] init]];
    
    for (int i=0;i<6;i++) {
        
        for (NSInteger j=startDay;j<7;j++) {
            
            UIView *contentView= [[UIView alloc] initWithFrame:CGRectMake( x, y, width, height )];
            contentView.tag= day;
            contentView.backgroundColor= [UIColor blackColor];
            [self addSubview:contentView];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( colorBarViewTapped: )];
            [contentView addGestureRecognizer:tapGestureRecognizer];

            UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, width, 20 )];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment= NSTextAlignmentCenter;
            label.font= [UIFont clientBodyFont];
            label.text= [NSString stringWithFormat:@"%d", day];
            label.textColor= UIColor.lightGrayColor;
            [contentView addSubview:label];
            
            UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 10, 20+10, width-20, width-20 )];
            view.hidden= YES;
            [contentView addSubview:view];
            
            [views addObject:view];
            
            day++;
            x+= width;
            
            if (day>monthLength)
                break;
        }
        
        {
            UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, y+height-1, frame.size.width, 1 )];
            view.backgroundColor= [UIColor lightGrayColor];
            [self addSubview:view];
        }
        
        if (day>monthLength)
            break;
        
        x= 0;
        y+= height;
        startDay= 0;
    }
    
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.bounds centerY:frame.size.height/2];
    [self addSubview:activityView];
    
    [ParseManager getImagesForMonth:date block:^( NSArray *pfObjects ) {
        
        [activityView removeFromSuperview];
        
        if ((pfObjects)&&(pfObjects.count)) {
            
            for (PFObject *pfObject in pfObjects) {

                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:pfObject.createdAt];
                NSInteger day= [dateComponents day];
                
                UIView *view= views[day];
                
                if (view.hidden) {
                    
                    ColorBarView *colorBarView= [[ColorBarView alloc] initWithFrame:CGRectMake( 0, view.frame.size.height/2-20/2, view.frame.size.width, 20 ) histogram:pfObject[kHistogram]];
                    colorBarView.tag= day;
                    colorBarView.mDate= pfObject.createdAt;
                    [view addSubview:colorBarView];
                    view.hidden= NO;
                    
                    [mColorBarViews addObject:colorBarView];
                    
                }
            }
        }
    }];
    
    return self;
}

//------------------------------------------------------------------------------
- (void)colorBarViewTapped:(UITapGestureRecognizer *)sender
//------------------------------------------------------------------------------
{
    for (ColorBarView *colorBarView in mColorBarViews) {
        if (colorBarView.tag==sender.view.tag) {
            [self.delegate shouldShowDayViewForDate:colorBarView.mDate];
            return;
        }
    }
}

@end