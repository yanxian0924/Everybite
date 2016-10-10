//
//  CMHistogramView.h
//  ColorMatch
//
//  Created by Grant Schindler on 6/5/14.
//  Copyright (c) 2014 Edison Thomaz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMMaskView.h"

#define kBins 8

@interface CMHistogramView : UIView

@property float *hueHistogram;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)resetHistogramWithMaskView:(CMMaskView *)maskView;
- (void)fillHistogram: (float[]) hueArray ofSize: (int) nrBins;

@end

