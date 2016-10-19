//
//  StillViewController.m
//  EatHue
//
//  Created by Russell Mitchell on 1/11/15.
//  Copyright (c) 2015 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "CMMaskView.h"
#import "ParseManager.h"
#import "ActivityView.h"
#import "CMHistogramView.h"
#import "UIFont+ClientFont.h"
#import "DataViewController.h"
#import "StillViewController.h"

@interface StillViewController () <UITextFieldDelegate> {
    
    PFObject *mPFObject;
    UIButton *mEditButton;
    UIButton *mSaveButton;
    float mActivityCenterY;
    CMMaskView *mCMMaskView;
    CMHistogramView *mHistogramView;
    UITextField *mCaptionTextField;
    
}

@property( nonatomic, strong ) UIImage *mImage;

@end

@implementation StillViewController

//------------------------------------------------------------------------------
- (id)initWithImage:(UIImage *)image
//------------------------------------------------------------------------------
{
    if (!(self= [super init]))
        return nil;
    
    self.mImage= image;
    
    return self;
}

//------------------------------------------------------------------------------
- (UIImage *)imageFromView:(UIView *)view
//------------------------------------------------------------------------------
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    self.view.backgroundColor= [UIColor blackColor];
    
    float width= self.view.frame.size.width;

    UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20, width, width )];
    view.backgroundColor= [UIColor clearColor];
    view.layer.masksToBounds= YES;
    [self.view addSubview:view];
    
    mActivityCenterY= view.frame.origin.y + view.frame.size.width/2;
    
    UIImageView *imageView= [[UIImageView alloc] initWithFrame:view.bounds];
    [imageView setImage:self.mImage];
    [view addSubview:imageView];
    
    // histogram/edit mask is wonked up (off by 90deg) if we use the rotated image
    // workaround: take a snapshot of the current imageview
    
    self.mImage= [self imageFromView:imageView];
    
    mCMMaskView= [[CMMaskView alloc] initWithFrame:imageView.bounds];
    mCMMaskView.hidden= YES;
    [view addSubview:mCMMaskView];
    
    float y= 5 + view.frame.size.height+20;
    float capHeight = 44;
    
    // caption text field
    mCaptionTextField= [[UITextField alloc] initWithFrame:CGRectMake( 10, y, width - 20, capHeight )];
    mCaptionTextField.borderStyle = UITextBorderStyleNone;
    mCaptionTextField.font= [UIFont clientBodyFont];
    mCaptionTextField.textColor= [UIColor lightGrayColor];
    mCaptionTextField.attributedPlaceholder= [[NSAttributedString alloc] initWithString:@"Enter caption" attributes:@{NSForegroundColorAttributeName:UIColor.lightGrayColor}];
    mCaptionTextField.returnKeyType = UIReturnKeyDone;
    mCaptionTextField.delegate = self;
    [self.view addSubview:mCaptionTextField];
    
    y += 5 + capHeight;
    float height = self.view.frame.size.height-20-44-20 - y;
    
    mHistogramView= [[CMHistogramView alloc] initWithFrame:CGRectMake( 0, y, self.view.frame.size.width, height ) image:self.mImage];
    [self.view addSubview:mHistogramView];
    
    
    float x= 0;
    width= self.view.frame.size.width/3;
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( x, self.view.frame.size.height-44, width, 44 );
        [button addTarget:self action:@selector( retakeButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Retake" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    x+= width;
    {
        mEditButton= [UIButton buttonWithType:UIButtonTypeSystem];
        mEditButton.frame= CGRectMake( x, self.view.frame.size.height-44, width, 44 );
        [mEditButton addTarget:self action:@selector( editButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [mEditButton setTitle:@"Edit" forState:UIControlStateNormal];
        [mEditButton.titleLabel setFont:[UIFont clientTitleFont]];
        [mEditButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:mEditButton];
    }
    x+= width;
    {
        mSaveButton= [UIButton buttonWithType:UIButtonTypeSystem];
        mSaveButton.frame= CGRectMake( x, self.view.frame.size.height-44, width, 44 );
        [mSaveButton addTarget:self action:@selector( saveButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [mSaveButton setTitle:@"Save" forState:UIControlStateNormal];
        [mSaveButton.titleLabel setFont:[UIFont clientTitleFont]];
        [mSaveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.view addSubview:mSaveButton];
    }
}

//------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//------------------------------------------------------------------------------
{
    [textField resignFirstResponder];
        
    return YES;
}
    
//------------------------------------------------------------------------------
- (void)retakeButtonPressed
//------------------------------------------------------------------------------
{
    [self.navigationController popViewControllerAnimated:NO];
}

//------------------------------------------------------------------------------
- (void)editButtonPressed
//------------------------------------------------------------------------------
{
    if ([mEditButton.titleLabel.text isEqualToString:@"Edit"]) {
        
        [mEditButton setTitle:@"Done" forState:UIControlStateNormal];
        mSaveButton.hidden= YES;
        
        mCMMaskView.hidden= NO;
        [mCMMaskView allFalseMask];
        [mCMMaskView setNeedsDisplay];
        mCMMaskView.userInteractionEnabled = YES;
        
    } else {
        
        [mEditButton setTitle:@"Edit" forState:UIControlStateNormal];
        mSaveButton.hidden= NO;

        mCMMaskView.hidden= YES;
        mCMMaskView.userInteractionEnabled = NO;
        [mHistogramView resetHistogramWithMaskView:mCMMaskView];
        [mHistogramView setNeedsDisplay];
        
    }
}

//------------------------------------------------------------------------------
- (void)saveButtonPressed
//------------------------------------------------------------------------------
{
    if (mPFObject) {
        
        DataViewController *dataViewController= [[DataViewController alloc] init];
        [self.navigationController pushViewController:dataViewController animated:YES];
        
        return;
    }
    
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds centerY:mActivityCenterY];
    [self.view addSubview:activityView];

    NSMutableArray *histogram= [[NSMutableArray alloc] init];
    
    for (int i=0;i<kBins;i++)
        histogram[i]= [NSNumber numberWithFloat:mHistogramView.hueHistogram[i]];
    
    CGSize size= CGSizeMake( 200, 200 );
    UIGraphicsBeginImageContextWithOptions( size, NO, 0.0 );
    [self.mImage drawInRect:CGRectMake( 0, 0, size.width, size.height )];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *caption;
    
    if ([mCaptionTextField.text length]) {
        caption = mCaptionTextField.text;
    }
    
    [ParseManager uploadImage:image histogram:histogram caption:caption block:^( PFObject *pfObject ) {
        
        [activityView removeFromSuperview];
        
        if (pfObject) {
            
            mPFObject= pfObject;;
            
            DataViewController *dataViewController= [[DataViewController alloc] init];
            [self.navigationController pushViewController:dataViewController animated:YES];
            
        }
    }];
}

@end
