//
//  MonthView.h
//  EatHue
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
