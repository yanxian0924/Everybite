//
//  CMMaskView.m
//  ColorMatch
//
//  Created by Grant Schindler on 7/28/14.
//  Copyright (c) 2014 Edison Thomaz. All rights reserved.
//

#import "CMMaskView.h"

float mask[kMaskSize];

@implementation CMMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor= [UIColor clearColor];
        
        for (int i = 0; i < kMaskSize; i++)
            mask[i] = true;

    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        for (int i = 0; i < kMaskSize; i++){
            mask[i] = true;
        }
        NSLog(@"Initialized with Coder");
    }
    return self;
}

-(bool) maskValue: (int) index{
    return mask[index];
}

-(void) allTrueMask{
    for (int i = 0; i < kMaskSize; i++){
        mask[i] = true;
    }
}

-(void) allFalseMask{
    for (int i = 0; i < kMaskSize; i++){
        mask[i] = false;
    }
}

-(void) fillMask: (bool[]) maskArray
{
    for (int i = 0; i < kMaskSize; i++){
        mask[i] = maskArray[i];
    }
}

-(void) randomizeMask{
    for (int i = 0; i < kMaskSize; i++){
        mask[i] = (rand()%10 > 5) ? true : false;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved: touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    float width  = self.bounds.size.width;
    float height = self.bounds.size.height;
    int maskWidth = (int)(sqrt(kMaskSize));
    
    //Multiple Pixels in Mask
    int brushWidth = kBrushSize;
    for (int a = - brushWidth/2; a <= brushWidth/2; a++){
        for (int b = - brushWidth/2; b <= brushWidth/2; b++){
            int x = ((touchPoint.x/width) * maskWidth) + a;
            int y = (int)((touchPoint.y/height) * maskWidth) + b;
            if (x >= 0 && x < maskWidth && y >= 0 && y < maskWidth){
                int i = x +  y * maskWidth;
                mask[i] = true;
            }
        }
    }
    
    //Redraw as we paint
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();   //TODO: Clear Everything each draw - do we want this for calibration?
    CGContextClearRect(ctx, rect);
    
    // Drawing code
    //[[UIColor blackColor] setStroke];
    //[[UIColor whiteColor] setFill];
    
    float width  = self.bounds.size.width;
    //float height = self.bounds.size.height;
    
    int maskWidth = (int)(sqrt(kMaskSize));
    float maskPixelWidth = width / (float)maskWidth;
    
    for (int c = 0; c < kMaskSize; c++){
        
        float x = c % maskWidth;
        float y = c / maskWidth;

        CGRect pixel = CGRectMake(  x * maskPixelWidth,
                                    y * maskPixelWidth,
                                    maskPixelWidth, maskPixelWidth);

        if (mask[c] == true){
            [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] setFill];
        }
        else{
            [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6] setFill];
        }

        CGContextFillRect(ctx, pixel);
        
    }//for c
    
    //NSLog(@"Draw mask");
}


@end
