//
//  ColorWheelView.h
//  EatHue
//
//------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ColorWheelView : UIView

- (id)initWithFrame:(CGRect)frame histogram:(NSArray *)histogram;

@property float mGrade;
@property float mNumColors;
@property( nonatomic, strong ) NSDate *mDate;

@end
