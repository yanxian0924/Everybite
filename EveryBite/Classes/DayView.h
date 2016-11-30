//
//  DayView.h
//  EatHue
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface DayView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

- (void)reinitWithDate:(NSDate *)date;

@end
