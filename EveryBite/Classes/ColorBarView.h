//
//  ColorBarView.h
//  EatHue
//
//  Created by Russell Mitchell on 3/16/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorBarView : UIView

- (id)initWithFrame:(CGRect)frame histogram:(NSArray *)histogram;

@property float mGrade;
@property float mNumColors;
@property( nonatomic, strong ) NSDate *mDate;

@end
