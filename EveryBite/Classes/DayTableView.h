//
//  DayTableView.h
//  EatHue
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface DayTableView : UIView

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;

@property( nonatomic, strong ) NSDate *mDate;

@end
