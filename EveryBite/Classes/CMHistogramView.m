//
//  CMHistogramView.m
//  ColorMatch
//
//  Created by Grant Schindler on 6/5/14.
//  Copyright (c) 2014 Edison Thomaz. All rights reserved.
//

#import "CMHistogramView.h"

@interface CMHistogramView() {
    
    UIImage *mImage;
    
}

@end

float maxValue;

int nrHistogramBins;

@implementation CMHistogramView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        mImage= image;
        
        _hueHistogram= malloc( sizeof( float) * kBins );
        
        nrHistogramBins = kBins;
        
        [self getHueHistogramFromImage:image];
        
        maxValue = -1.0;

        for (int i = 0; i < nrHistogramBins; i++){
            if (_hueHistogram[i] > maxValue){
                maxValue = _hueHistogram[i];
            }
        }
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        nrHistogramBins = kBins;
        maxValue = -1.0;
        for (int i = 0; i < nrHistogramBins; i++){
            _hueHistogram[i] = i + 1.0;
            if (_hueHistogram[i] > maxValue){
                maxValue = _hueHistogram[i];
            }
        }
        NSLog(@"Initialized with Coder");
    }
    return self;
}

-(void) fillHistogram: (float[]) hueArray
               ofSize: (int) nrBins
{
    nrHistogramBins = nrBins;
    maxValue = -1.0;
    for (int i = 0; i < nrHistogramBins; i++){
        _hueHistogram[i] = hueArray[i];
        if (_hueHistogram[i] > maxValue){
            maxValue = _hueHistogram[i];
        }
    }
}

- (void) getHueHistogramFromImage:(UIImage*)image
{
    //NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    nrHistogramBins = kBins;
    for (int i = 0; i < nrHistogramBins; i++){
        _hueHistogram[i] = 0.0;
    }
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = 0; //(bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < (width*height) ; ii++)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;
        CGFloat alpha2;
        [acolor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha2];        
        
        //Standard Rainbow 8-color histogram
        if (nrHistogramBins == 8){
            
            float redMax    =  15.0/360.0;
            float orangeMax =  44.0/360.0;
            float yellowMax =  80.0/360.0;
            float greenMax  = 156.0/360.0;
            float blueMax   = 255.0/360.0;
            float purpleMax = 345.0/360.0;
            
            float value = 1.0; //Could be brightness instead to have weighted histogram with brighter colors adding more weight
            
            if (saturation > 0.2){
                if (brightness > 0.2){
                    if (hue > purpleMax || hue <= redMax){
                        _hueHistogram[0] += value; //Red
                    }
                    else if (hue > redMax && hue <= orangeMax){
                        _hueHistogram[1] += value; //Orange
                    }
                    else if (hue > orangeMax && hue <=yellowMax){
                        _hueHistogram[2] += value; //Yellow
                    }
                    else if (hue > yellowMax && hue <=greenMax){
                        _hueHistogram[3] += value; //Green
                    }
                    else if (hue > greenMax && hue <=blueMax){
                        _hueHistogram[4] += value; //Blue
                    }
                    else if (hue > blueMax && hue <=purpleMax){
                        _hueHistogram[5] += value; //Purple
                    }
                }//end brightness
                else{
                    _hueHistogram[6] += value; //Black - TODO: if value isn't just 1.0, see what that means
                }
            }//end saturation
            else{
                _hueHistogram[7] += value; //White -- TODO: how best to count this
            }
            
        }
        else{ //Continuous-ish Hue Histogram
            
            if (saturation > 0.2){
                if (brightness > 0.2){
                    
                    float value = saturation * brightness; //1.0;
                    int bin = (int)(hue * (float)(nrHistogramBins-1));
                    _hueHistogram[bin] += value;
                    
                }//end brightness
            }//end saturation
        }//end continuous histogram
        
        //[result addObject:acolor];
    }
    
    free(rawData);
    
    //return result;
}

- (void)resetHistogramWithMaskView:(CMMaskView *)maskView
{
    nrHistogramBins = kBins;
    for (int i = 0; i < nrHistogramBins; i++){
        _hueHistogram[i] = 0.0;
    }
    
    // First get the image into your data buffer
    CGImageRef imageRef = [mImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int maskWidth = (int)(sqrt(kMaskSize));
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = 0; //(bytesPerRow * yy) + xx * bytesPerPixel;
    for (int ii = 0 ; ii < (width*height) ; ii++)
    {
        int ix = ii % width;
        int iy = ii / width;
        
        int x = (int)(((float)ix/(float)width) * maskWidth);
        int y = (int)(((float)iy/(float)height) * maskWidth);
        int i = x +  y * maskWidth;
        
        //int i = (int)(sqrt((float)kMaskSize) * ((float)x / (float)width));
        //int i = (int)((float)kMaskSize * ((float)ii / (float)(width*height)));
        
        
        
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        if ([maskView maskValue:i]){ //true pixel according to mask
            
            UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            CGFloat hue;
            CGFloat saturation;
            CGFloat brightness;
            CGFloat alpha2;
            [acolor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha2];
            
            //Standard Rainbow 8-color histogram
            if (nrHistogramBins == 8){
                
                float redMax    =  15.0/360.0;
                float orangeMax =  44.0/360.0;
                float yellowMax =  80.0/360.0;
                float greenMax  = 156.0/360.0;
                float blueMax   = 255.0/360.0;
                float purpleMax = 345.0/360.0;
                
                float value = 1.0; //Could be brightness instead to have weighted histogram with brighter colors adding more weight
                
                if (saturation > 0.2){
                    if (brightness > 0.2){
                        if (hue > purpleMax || hue <= redMax){
                            _hueHistogram[0] += value; //Red
                        }
                        else if (hue > redMax && hue <= orangeMax){
                            _hueHistogram[1] += value; //Orange
                        }
                        else if (hue > orangeMax && hue <=yellowMax){
                            _hueHistogram[2] += value; //Yellow
                        }
                        else if (hue > yellowMax && hue <=greenMax){
                            _hueHistogram[3] += value; //Green
                        }
                        else if (hue > greenMax && hue <=blueMax){
                            _hueHistogram[4] += value; //Blue
                        }
                        else if (hue > blueMax && hue <=purpleMax){
                            _hueHistogram[5] += value; //Purple
                        }
                    }//end brightness
                    else{
                        _hueHistogram[6] += value; //Black - TODO: if value isn't just 1.0, see what that means
                    }
                }//end saturation
                else{
                    _hueHistogram[7] += value; //White -- TODO: how best to count this
                }
                
            }
            else{ //Continuous-ish Hue Histogram
                
                if (saturation > 0.2){
                    if (brightness > 0.2){
                        
                        float value = saturation * brightness; //1.0;
                        int bin = (int)(hue * (float)(nrHistogramBins-1));
                        _hueHistogram[bin] += value;
                        
                    }//end brightness
                }//end saturation
            }//end continuous histogram
            
            //[result addObject:acolor];
            
        }//valid pixel by mask
        
    }//loop over pixels
    
    free(rawData);
    
    maxValue = -1.0;
    
    for (int i = 0; i < nrHistogramBins; i++){
        if (_hueHistogram[i] > maxValue){
            maxValue = _hueHistogram[i];
        }
    }
    
    //return result;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]]; //set in interface builder instead
    // Adjust the drawing options as needed.
    
    //Range for Brightness Values:
    //Min: -6.080933717900768
    //Max: 7.194535065004089
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();   //TODO: Clear Everything each draw - do we want this for calibration?
    CGContextClearRect(ctx, rect);
    
    // Drawing code
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    float width  = self.bounds.size.width;
    float height = self.bounds.size.height;
    float heightOfPlot = height * 0.9;
    float padding = width * 0.05;
    //NSLog(@"w:%f, h:%f", width, height);
    //float redMax = response[kNrValues][0];
    //float greenMax = response[kNrValues][1];
    //float blueMax = response[kNrValues][2];
    //float valueMax = fmax(fmax(redMax,greenMax),blueMax);
    //NSLog(@"ValueMax = %f",valueMax);
    
    //Plot Fixed Grid - set valueMax to a constant to be able to visually compare curves across calibration runs
    //valueMax = 1.0; //255.0; //Fix valueMax for plotting purposes
    bool grid = false;
    if (grid){
        CGFloat pattern[2] = {4.0,2.0};
        int nrGridLines = 10;
        for (int gridLine = 0; gridLine <= nrGridLines; gridLine++){
            UIBezierPath* gridPath = [UIBezierPath bezierPath];  gridPath.lineWidth = 1; [gridPath setLineDash:pattern count:2 phase:0];
            [gridPath moveToPoint:CGPointMake(0.5*padding,(height - heightOfPlot) + heightOfPlot * (1.0 - (float)gridLine/(float)nrGridLines))];
            [gridPath addLineToPoint:CGPointMake(width-0.5*padding,(height - heightOfPlot) +  heightOfPlot * (1.0 - (float)gridLine/(float)nrGridLines))];
            [[UIColor grayColor] setStroke];
            [gridPath stroke];
        }
    }
    
    for (int c = 0; c < nrHistogramBins; c++){
        if (_hueHistogram[c] > 0.0){
            float xVal = 0.5*padding + (width-padding)*(((float)c)/(float)nrHistogramBins);
            
            CGRect bar = CGRectMake(
                                   xVal,
                                   height * 0.95,
                                   0.8 * (width/(float)nrHistogramBins),
                                    -(height * 0.9 * _hueHistogram[c]/maxValue));
            
            /*UIBezierPath* pixel = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                              xVal,
                                                                              heightOfPlot,
                                                                              width/(float)nrHistogramBins,
                                                                             -(heightOfPlot * hueHistogram[c]/maxValue))
                                   ];
             */
            
            
            //Set Color
            if (nrHistogramBins == 8){
                switch(c){
                    case 0:[[UIColor redColor] setFill]; break;
                    case 1:[[UIColor orangeColor] setFill]; break;
                    case 2:[[UIColor yellowColor] setFill]; break;
                    case 3:[[UIColor greenColor] setFill]; break;
                    case 4:[[UIColor blueColor] setFill]; break;
                    case 5:[[UIColor purpleColor] setFill]; break;
                    case 6:[[UIColor blackColor] setFill]; break;
                    case 7:[[UIColor whiteColor] setFill]; break;
                    default:[[UIColor darkGrayColor] setFill]; break;
                }
                [[UIColor lightGrayColor] setStroke];
                CGContextStrokeRect(ctx, bar);
                
            }
            else{
                [[UIColor colorWithHue:((float)c/(float)nrHistogramBins) saturation:1.0 brightness:1.0 alpha:1.0] setFill];
            }
            //[pixel stroke];
            
            CGContextFillRect(ctx, bar);
            
           
            
        }

    }
    
}


@end
