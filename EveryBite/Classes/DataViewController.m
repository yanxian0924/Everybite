//
//  DataViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 1/11/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "DayView.h"
#import "MonthView.h"
#import "AppDelegate.h"
#import "ParseManager.h"
#import "CMHistogramView.h"
#import "UIFont+ClientFont.h"
#import "DataViewController.h"
#import "LiveViewController.h"
#import "UIColor+ClientColor.h"

@interface DataViewController () <MonthViewDelegate> {
    
    DayView *mDayView;
    UIButton *mDayButton;
    MonthView *mMonthView;
    UIButton *mMonthButton;
    
}

@property( nonatomic, strong ) PFObject *mPFObject;

@end

@implementation DataViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    self.view.backgroundColor= UIColor.blackColor;
    
    mDayView= [[DayView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height-44-1 ) date:[NSDate date]];
    [self.view addSubview:mDayView];
    
    float y= self.view.frame.size.height-44-1;
    
    // separator line
    
    {
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, y, self.view.frame.size.width, 1 )];
        view.backgroundColor= [UIColor lightGrayColor];
        [self.view addSubview:view];
    }
    
    y+= 1;
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 0, y, self.view.frame.size.width/3, 44 );
        [button addTarget:self action:@selector( cameraButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Camera" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    {
        mDayButton= [UIButton buttonWithType:UIButtonTypeSystem];
        mDayButton.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
        mDayButton.frame= CGRectMake( self.view.frame.size.width/3, y, self.view.frame.size.width/3, 44 );
        [mDayButton addTarget:self action:@selector( dayButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [mDayButton setTitle:@"Day" forState:UIControlStateNormal];
        [mDayButton.titleLabel setFont:[UIFont clientTitleFont]];
        [mDayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:mDayButton];
    }
    {
        mMonthButton= [UIButton buttonWithType:UIButtonTypeSystem];
        mMonthButton.frame= CGRectMake( self.view.frame.size.width/3*2, y, self.view.frame.size.width/3, 44 );
        [mMonthButton addTarget:self action:@selector( monthButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [mMonthButton setTitle:@"Month" forState:UIControlStateNormal];
        [mMonthButton.titleLabel setFont:[UIFont clientTitleFont]];
        [mMonthButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:mMonthButton];
    }
}

//------------------------------------------------------------------------------
- (void)cameraButtonPressed
//------------------------------------------------------------------------------
{
    LiveViewController *liveViewController;
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[LiveViewController class]]) {
            liveViewController= (LiveViewController *)viewController;
            break;
        }
    }
    
    [self.navigationController popToViewController:liveViewController animated:NO];
}

//------------------------------------------------------------------------------
- (void)dayButtonPressed
//------------------------------------------------------------------------------
{
    [self.view bringSubviewToFront:mDayView];
    
    mMonthButton.backgroundColor= [UIColor clearColor];
    [mMonthButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    [mDayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mDayButton.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
}

//------------------------------------------------------------------------------
- (void)monthButtonPressed
//------------------------------------------------------------------------------
{
    if (!mMonthView) {
        mMonthView= [[MonthView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height-44-1 ) date:[NSDate date]];
        mMonthView.delegate= self;
        [self.view addSubview:mMonthView];
    } else {
        [self.view bringSubviewToFront:mMonthView];
    }
    
    mDayButton.backgroundColor= [UIColor clearColor];
    [mDayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    mMonthButton.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    [mMonthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

//------------------------------------------------------------------------------
- (void)shouldShowDayViewForDate:(NSDate *)date
//------------------------------------------------------------------------------
{
    [self.view bringSubviewToFront:mDayView];
    [mDayView reinitWithDate:date];
    
    mMonthButton.backgroundColor= [UIColor clearColor];
    [mMonthButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [mDayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mDayButton.backgroundColor= [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
}

@end
