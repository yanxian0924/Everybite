//
//  DayTableView.m
//  EatHue
//
//------------------------------------------------------------------------------

#import "ImageCache.h"
#import "DayTableView.h"
#import "MyParseManager.h"
#import "ActivityView.h"
#import "ColorBarView.h"
#import "UIFont+ClientFont.h"
#import "UIColor+ClientColor.h"
#import "UIImage+Util.h"

@interface DayTableView() <UITableViewDataSource,UITableViewDelegate> {
    
}

//@property( nonatomic, strong ) UIImage *image;
@property( nonatomic, strong ) NSArray *mPFObjects;
@property( nonatomic, strong ) UIView *largeImageView;
@property( nonatomic, strong ) UIView *largeImageContentView;

@end

@implementation DayTableView

//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame date:(NSDate *)date
//------------------------------------------------------------------------------
{
    if (!(self=[super initWithFrame:frame]))
        return nil;
    
    self.mDate= date;
    self.backgroundColor= UIColor.blackColor;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd"];
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake( 0, 20, frame.size.width, 44 )];
    label.text= [dateFormatter stringFromDate:date];
    label.textAlignment= NSTextAlignmentCenter;
    label.backgroundColor= UIColor.blackColor;
    label.textColor= [UIColor lightGrayColor];
    [label setFont:[UIFont clientTitleFont]];
    [self addSubview:label];

    // separator line
    
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, 20+43, frame.size.width, 1 )];
    view.backgroundColor= [UIColor lightGrayColor];
    [self addSubview:view];
    
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.bounds centerY:frame.size.height/2];
    [self addSubview:activityView];
    
    [MyParseManager getImagesForDay:date block:^( NSArray *pfObjects ) {
        
        [activityView removeFromSuperview];
        
        if ((pfObjects)&&(pfObjects.count)) {
            
            self.mPFObjects= pfObjects;
            
            UITableView *tableView= [[UITableView alloc] initWithFrame:CGRectMake( 0, 20+44, frame.size.width, frame.size.height-20-44 )];
            tableView.delegate= self;
            tableView.dataSource= self;
            tableView.bounces= NO;
            tableView.separatorColor= [UIColor clearColor];
            tableView.backgroundColor= UIColor.blackColor;
            tableView.contentInset= UIEdgeInsetsMake( 0, 0, 0, 0 );
            [self addSubview:tableView];
                        
        }
    }];
    
    return self;
}

//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//------------------------------------------------------------------------------
{
    return [self.mPFObjects count];
}

//------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//------------------------------------------------------------------------------
{
    return 100;
}

#define kGradeA 5
#define kGradeB 4
#define kGradeC 3
#define kGradeD 2
#define kGradeF 1

//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//------------------------------------------------------------------------------
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell-%ld", (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle= UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor= UIColor.blackColor;
        PFObject *pfObject= self.mPFObjects[indexPath.row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"   hh:mm a"];
        
        float x= 0;
        
        UILabel *timeLabel= [[UILabel alloc] initWithFrame:CGRectMake( x, 100/2-30/2, 100, 30 )];
        timeLabel.backgroundColor= [UIColor clearColor];
        timeLabel.textAlignment= NSTextAlignmentLeft;
        timeLabel.font= [UIFont clientBodyFont];
        timeLabel.text= [dateFormatter stringFromDate:pfObject.createdAt];
        timeLabel.textColor= UIColor.lightGrayColor;
        [cell.contentView addSubview:timeLabel];
        
        UILabel *gradeLabel= [[UILabel alloc] initWithFrame:CGRectMake( x, 100/2, 100, 30 )];
        gradeLabel.backgroundColor= [UIColor clearColor];
        gradeLabel.textAlignment= NSTextAlignmentLeft;
        gradeLabel.font= [UIFont clientBodyFont];
        [cell.contentView addSubview:gradeLabel];
        
        x+= 100;
        
        {
            UIView *view= [[UIView alloc] initWithFrame:CGRectMake( x, 0, 1, 100 )];
            view.backgroundColor= UIColor.lightGrayColor;
            [cell.contentView addSubview:view];
        }
        
        x+= 10;
        
        ColorBarView *colorBarView= [[ColorBarView alloc] initWithFrame:CGRectMake( x+10, 100/2-40/2, 80, 40 ) histogram:pfObject[kHistogram]];
        [cell.contentView addSubview:colorBarView];
        
        x+= 100 + 10;
        
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake( x, 10, 80, 80 )];
        view.layer.borderColor= [[UIColor blackColor] CGColor];
        view.layer.borderWidth= 1;
        view.backgroundColor= [UIColor clearColor];
        [cell.contentView addSubview:view];
        
        UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 80, 80 )];
        UIImage *img = [ImageCache imageNamed:pfObject.objectId];
        imageView.image = [UIImage drawText:pfObject[kCaption]
                                    inImage:img
                                    atPoint:CGPointMake(5, img.size.height - 36)];
        imageView.layer.borderColor= [[UIColor blackColor] CGColor];
        imageView.layer.borderWidth= 1;
        imageView.userInteractionEnabled= YES;
        [view addSubview:imageView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( imageViewTapped: )];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        
    }
    
    return cell;
}

//------------------------------------------------------------------------------
- (void)imageViewTapped:(UITapGestureRecognizer *)sender
//------------------------------------------------------------------------------
{
    UIImageView *imageView= (UIImageView *)sender.view;
    
    self.largeImageView= [[UIView alloc] initWithFrame:self.bounds];
    self.largeImageView.backgroundColor= [UIColor blackColor];
    self.largeImageView.alpha= 0;
    [self addSubview:self.largeImageView];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( dismissLargeImageView )];
    [self.largeImageView addGestureRecognizer:tapGestureRecognizer];

    UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame= CGRectMake( 320-60, 20, 60, 44 );
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont clientBodyFont]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector( dismissLargeImageView ) forControlEvents:UIControlEventTouchDown];
    [self.largeImageView addSubview:button];

    UIView *separatorView= [[UIView alloc] initWithFrame:CGRectMake( 0, 20+44, 320, 1 )];
    separatorView.backgroundColor= [UIColor lightGrayColor];
    [self.largeImageView addSubview:separatorView];
    
    self.largeImageContentView= [[UIView alloc] initWithFrame:CGRectMake( 0, self.frame.size.height, 320, 320+44 )];
    self.largeImageContentView.backgroundColor= [UIColor blackColor];
    [self.largeImageView addSubview:self.largeImageContentView];
    
    UIImageView *newImageView= [[UIImageView alloc] initWithFrame:CGRectMake( 0, 44, 320, 320 )];
    [newImageView setImage:imageView.image];
    [self.largeImageContentView addSubview:newImageView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.largeImageView.alpha = 1;
        self.largeImageContentView.frame= CGRectMake( 0, self.frame.size.height/2 - (280+44)/2, 320, 320+44 );
    }];
}

//------------------------------------------------------------------------------
- (void)dismissLargeImageView
//------------------------------------------------------------------------------
{
    [UIView animateWithDuration:0.5 animations:^{
        self.largeImageView.alpha = 0;
        self.largeImageContentView.frame= CGRectMake( 0, self.frame.size.height, 320, 320+44 );
    } completion:^(BOOL finished){
        [self.largeImageView removeFromSuperview];
    }];
}

@end
