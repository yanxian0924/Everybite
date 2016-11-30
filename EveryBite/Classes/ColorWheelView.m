//
//  ColorWheelView.m
//  EatHue
//
//------------------------------------------------------------------------------

#import "ColorWheelView.h"
#import "DataViewController.h"

@implementation ColorWheelView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame histogram:(NSArray *)histogram
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;
    
    NSMutableArray *colors= [[NSMutableArray alloc] init];
    [colors addObject:[UIColor redColor]];
    [colors addObject:[UIColor orangeColor]];
    [colors addObject:[UIColor yellowColor]];
    [colors addObject:[UIColor greenColor]];
    [colors addObject:[UIColor blueColor]];
    [colors addObject:[UIColor purpleColor]];
    [colors addObject:[UIColor whiteColor]];
    [colors addObject:[UIColor blackColor]];

    NSMutableArray *frames= [[NSMutableArray alloc] init];

    float width= frame.size.width / 4;
    float delta = frame.size.width / 8;
    float x= delta * 3;
    float y= 0;
 
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];
    
    x+= width;
    y+= delta;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];
    
    x+= delta;
    y+= width;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];

    x-= delta;
    y+= width;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];

    x-= width;
    y+= delta;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];

    x-= width;
    y-= delta;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];

    x-= delta;
    y-= width;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];

    x+= delta;
    y-= width;
    [frames addObject:[NSValue valueWithCGRect:CGRectMake( x, y, width, width )]];
    
    float maxColorValue= 0;
    
    for (int i=0;i<8;i++) {
        if ([histogram[i] floatValue] > maxColorValue) {
            maxColorValue= [histogram[i] floatValue];
        }
    }

    self.mNumColors= 0;
    
    for (int i=0;i<8;i++) {

        // only show color if the value is at least 1% of the max color
        
        float colorValue= [histogram[i] floatValue];
        BOOL showColor= ( colorValue/maxColorValue*100 > 1);
        
        if (showColor)
            self.mNumColors++;
        
        UIView *view= [[UIView alloc] initWithFrame:[frames[i] CGRectValue]];
        view.backgroundColor= (showColor)?colors[i]:[UIColor clearColor];
        view.layer.cornerRadius= width/2;
        view.layer.masksToBounds= YES;
        view.layer.borderColor= [[UIColor blackColor] CGColor];
        view.layer.borderWidth= 1;
        [self addSubview:view];
        
    }

    self.mGrade= self.mNumColors / 8 * 100;
    
    return self;
}

@end
