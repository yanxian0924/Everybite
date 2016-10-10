//
//  CMMaskView.h
//  ColorMatch
//
//  Created by Grant Schindler on 7/28/14.
//  Copyright (c) 2014 Edison Thomaz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMaskSize 40*40
#define kBrushSize 5
//256*256

@interface CMMaskView : UIView

-(void) fillMask: (bool[]) maskArray;
-(void) allTrueMask;
-(void) allFalseMask;
-(void) randomizeMask;
-(bool) maskValue: (int) index;

@end
