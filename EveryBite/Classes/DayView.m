//
//  DayView.m
//  EatHue
//
//------------------------------------------------------------------------------

#import "DayView.h"
#import "AppDelegate.h"
#import "DayTableView.h"
#import "ActivityView.h"
#import "MyParseManager.h"
#import "DataViewController.h"

@interface DayView () <UIScrollViewDelegate> {
    
    NSInteger mDay;
    UIScrollView *mScrollView;
    
}

@property( nonatomic, strong ) NSDate *mDate;

@end

@implementation DayView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame date:(NSDate *)date
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;

    self.backgroundColor= [UIColor whiteColor];
    self.mDate= date;
    
    mScrollView= [[UIScrollView alloc] initWithFrame:CGRectMake( 0, 0, frame.size.width,  frame.size.height )];
    mScrollView.pagingEnabled= YES;
    mScrollView.bounces= NO;
    mScrollView.delegate= self;
    mScrollView.backgroundColor= [UIColor blackColor];
    mScrollView.contentInset= UIEdgeInsetsMake( -20, 0, 0, 0 );
    mScrollView.scrollIndicatorInsets= UIEdgeInsetsMake( 0, 0, 0, 0 );
    [self addSubview:mScrollView];
    
    mDay= 0;
    
    mScrollView.contentSize= CGSizeMake( frame.size.width*2, frame.size.height );
    mScrollView.contentOffset= CGPointMake( frame.size.width, 20 );

    DayTableView *dayTableView= [[DayTableView alloc] initWithFrame:CGRectMake( frame.size.width, 0, frame.size.width, frame.size.height ) date:date];
    [mScrollView addSubview:dayTableView];
    
    return self;    
}

//------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//------------------------------------------------------------------------------
{
    if (scrollView == mScrollView) {
        
        for (UIView *view in mScrollView.subviews) {
            if ([view isKindOfClass:[DayTableView class]]) {
                if (view.frame.origin.x == mScrollView.contentOffset.x) {
                    return;
                }
            }
        }
        
        if (mScrollView.contentOffset.x<=0) {  // we scrolled left
        
            NSDate *oldDate= nil;
            
            for (UIView *view in mScrollView.subviews) {
                if ([view isKindOfClass:[DayTableView class]]) {
                    if (view.frame.origin.x == self.frame.size.width) {
                        DayTableView *dayTableView= (DayTableView *)view;
                        oldDate= dayTableView.mDate;
                    }
                }
            }

            NSDate *newDate= [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:oldDate options:0];
            
            DayTableView *dayTableView= [[DayTableView alloc] initWithFrame:CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height ) date:newDate];
            [mScrollView addSubview:dayTableView];
            
            for (UIView *view in mScrollView.subviews) {
                if ([view isKindOfClass:[DayTableView class]]) {
                    view.frame= CGRectMake( view.frame.origin.x+view.frame.size.width, 0, view.frame.size.width, view.frame.size.height );
                }
            }
            
            mScrollView.contentSize= CGSizeMake( mScrollView.contentSize.width+self.frame.size.width, self.frame.size.height );
            mScrollView.contentOffset= CGPointMake( self.frame.size.width, 0 );

        } else {

            NSDate *oldDate= nil;
            
            for (UIView *view in mScrollView.subviews) {
                if ([view isKindOfClass:[DayTableView class]]) {
                    if (view.frame.origin.x == mScrollView.contentOffset.x-self.frame.size.width) {
                        DayTableView *dayTableView= (DayTableView *)view;
                        oldDate= dayTableView.mDate;
                    }
                }
            }
            
            NSDate *newDate= [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:oldDate options:0];
            
            DayTableView *dayTableView= [[DayTableView alloc] initWithFrame:CGRectMake( mScrollView.contentOffset.x, 0, self.frame.size.width, self.frame.size.height ) date:newDate];
            [mScrollView addSubview:dayTableView];
            
            mScrollView.contentSize= CGSizeMake( mScrollView.contentSize.width+self.frame.size.width, self.frame.size.height );
            
        }
    }
}

//------------------------------------------------------------------------------
- (void)reinitWithDate:(NSDate *)date
//------------------------------------------------------------------------------
{
    NSMutableArray *removeList= [[NSMutableArray alloc] init];
    
    for (UIView *view in mScrollView.subviews) {
        if ([view isKindOfClass:[DayTableView class]]) {
            [removeList addObject:view];
        }
    }
    
    for (UIView *view in removeList)
        [view removeFromSuperview];
    
    mDay= 0;
    self.mDate= date;
    
    mScrollView.contentSize= CGSizeMake( self.frame.size.width*3, self.frame.size.height );
    mScrollView.contentOffset= CGPointMake( self.frame.size.width, 0 );

    DayTableView *dayTableView= [[DayTableView alloc] initWithFrame:CGRectMake( self.frame.size.width, 0, self.frame.size.width, self.frame.size.height ) date:date];
    [mScrollView addSubview:dayTableView];    
}

@end
