//
//  CalendarView.h
//  EatHue
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

#define kCalendarViewHeight 438

@protocol CalendarViewDelegate <NSObject>

- (void)shouldShowDayViewForDate:(NSDate *)date;

@end

@interface CalendarView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

@property NSInteger mYear;
@property( nonatomic, strong ) NSDate *mDate;
@property( nonatomic, weak ) id<CalendarViewDelegate>delegate;

@end
