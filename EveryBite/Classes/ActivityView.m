//
//  ActivityView.m
//  EatHue
//
//------------------------------------------------------------------------------

#import "ActivityView.h"

@implementation ActivityView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame centerY:(float)centerY
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;

    CGRect bounds= CGRectMake( 0, 0, frame.size.width, frame.size.height );
    
    UIView *view= [[UIView alloc] initWithFrame:bounds];
    view.backgroundColor= [UIColor clearColor];
    view.userInteractionEnabled= YES;
    [self addSubview:view];
    
    float width= 100;
    float height= 76;
    
    UIActivityIndicatorView *activityIndicatorView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame= CGRectMake( frame.size.width/2-width/2, centerY, width, height );
    activityIndicatorView.layer.cornerRadius= 10;
    activityIndicatorView.layer.masksToBounds= YES;
    activityIndicatorView.alpha= 0.75;
    activityIndicatorView.backgroundColor= [UIColor clearColor];
    
    [self addSubview:activityIndicatorView];
    
    [activityIndicatorView startAnimating];
    
    return self;
}

@end
