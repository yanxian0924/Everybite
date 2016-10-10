//
//  ColorBarView.m
//  EatHue
//
//  Created by Russell Mitchell on 3/16/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//

#import "ColorBarView.h"
#import "DataViewController.h"

@implementation ColorBarView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame histogram:(NSArray *)histogram
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;
    
    self.layer.borderWidth= 1;
    self.layer.borderColor= [[UIColor blackColor] CGColor];
    
    NSMutableArray *colors= [[NSMutableArray alloc] init];
    [colors addObject:[UIColor redColor]];
    [colors addObject:[UIColor orangeColor]];
    [colors addObject:[UIColor yellowColor]];
    [colors addObject:[UIColor greenColor]];
    [colors addObject:[UIColor blueColor]];
    [colors addObject:[UIColor purpleColor]];
    [colors addObject:[UIColor blackColor]];
    [colors addObject:[UIColor whiteColor]];
    
    float totColorValue= 0;
    
    for (int i=0;i<8;i++)
        totColorValue+= [histogram[i] floatValue];
    
    NSMutableArray *frames= [[NSMutableArray alloc] init];
    
    self.mNumColors= 0;
    
    for (int i=0;i<8;i++) {
        
        self.mNumColors++;
        NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
        dict[@"view"]= [[UIView alloc] init];
        dict[@"color"]= colors[i];
        dict[@"colorValue"]= [NSNumber numberWithFloat:[histogram[i] floatValue]];
        [frames addObject:dict];
        
    }

    NSArray *sortedArray = [frames sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2)
    {
        return [d1[@"colorValue"] compare:d2[@"colorValue"]];
    }];

    float x= 0;
    
    for (int i=self.mNumColors-1;i>=0;i--) {
        
        NSDictionary *dict= sortedArray[i];

        float w= [dict[@"colorValue"] floatValue] / totColorValue;
        
        UIView *view= dict[@"view"];
        view.frame= CGRectMake( x, 0, frame.size.width*w, frame.size.height );
        view.backgroundColor= dict[@"color"];
        [self addSubview:view];
        
        x+= view.frame.size.width;
        
    }
    
    return self;
}

@end
