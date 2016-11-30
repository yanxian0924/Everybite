//
//  LiveViewController.m
//  EatHue
//
//------------------------------------------------------------------------------

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ActivityView.h"
#import "AVCamPreviewView.h"
#import "UIFont+ClientFont.h"
#import "DataViewController.h"
#import "LiveViewController.h"
#import "StillViewController.h"
#import "ProfileViewController.h"

static void *RecordingContext = &RecordingContext;
static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface LiveViewController () {
    
    float mActivityCenterY;
    UIButton *mStillButton;
    AVCamPreviewView *mPreviewView;
    
}

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation LiveViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
//------------------------------------------------------------------------------
{
    [super viewDidLoad];

    self.view.backgroundColor= [UIColor blackColor];
    
    float width= self.view.frame.size.width;
    
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake( 0, self.view.frame.size.height/2-width/2, width, width )];
    view.layer.masksToBounds= YES;
    view.backgroundColor= [UIColor clearColor];
    [self.view addSubview:view];

    mActivityCenterY= view.frame.origin.y + view.frame.size.height/2;
    
    // camera frame is based on 16:9 ratio but is a child of a smaller frame.
    // This means that we're only seeing the top 320 pixels of the real camera image
    mPreviewView = [[AVCamPreviewView alloc] initWithFrame:CGRectMake( 0, 0, width, floor(width*16/9) )];
    [view addSubview:mPreviewView];
    
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 10+44, self.view.frame.size.height-20-44, self.view.frame.size.width-(2*54), 44 );
        [button addTarget:self action:@selector( snapStillImage ) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Snap" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont clientTitleFont]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( 10, self.view.frame.size.height-20-44, 44, 44 );
        [button setBackgroundImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( calendarButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    {
        UIButton *button= [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame= CGRectMake( self.view.frame.size.width-10-44, self.view.frame.size.height-20-44, 44, 44 );
        [button setBackgroundImage:[UIImage imageNamed:@"user"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector( profileButtonPressed ) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:button];
    }
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Setup the preview view
    [mPreviewView setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [LiveViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[mPreviewView layer] connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            [self setMovieFileOutput:movieFileOutput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
}

//------------------------------------------------------------------------------
- (BOOL)isSessionRunningAndDeviceAuthorized
//------------------------------------------------------------------------------
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

//------------------------------------------------------------------------------
+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
//------------------------------------------------------------------------------
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//------------------------------------------------------------------------------
{
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak LiveViewController *weakSelf = self;
        
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            LiveViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
            });
        }]];
        [[self session] startRunning];
    });
}

//------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

//------------------------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
//------------------------------------------------------------------------------
{
    return YES;
}

//------------------------------------------------------------------------------
- (BOOL)shouldAutorotate
//------------------------------------------------------------------------------
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

////------------------------------------------------------------------------------
//- (NSUInteger)supportedInterfaceOrientations
////------------------------------------------------------------------------------
//{
//    return UIInterfaceOrientationMaskAll;
//}

//------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//------------------------------------------------------------------------------
{
    [[(AVCaptureVideoPreviewLayer *)[mPreviewView layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

//------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//------------------------------------------------------------------------------
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [mStillButton setEnabled:YES];
            }
            else
            {
                [mStillButton setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//------------------------------------------------------------------------------
- (UIImage *)cropImage:(UIImage *)image
//------------------------------------------------------------------------------
{
    CGFloat width = MIN( image.size.width, image.size.height );
    CGRect clippedRect = CGRectMake( image.size.width/2 - width/2, 0, width, width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    return [UIImage imageWithCGImage:imageRef scale:1.0 orientation:3];
}

//------------------------------------------------------------------------------
- (void)snapStillImage
//------------------------------------------------------------------------------
{
    ActivityView *activityView= [[ActivityView alloc] initWithFrame:self.view.bounds centerY:mActivityCenterY];
    [self.view addSubview:activityView];

    dispatch_async([self sessionQueue], ^{
        
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[mPreviewView layer] connection] videoOrientation]];
        
        // Flash set to Auto for Still Capture
        [LiveViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

            [activityView removeFromSuperview];
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];

                StillViewController *stillViewController= [[StillViewController alloc] initWithImage:[self cropImage:image]];
                [self.navigationController pushViewController:stillViewController animated:YES];
            }
        }];
    });
}

//------------------------------------------------------------------------------
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
//------------------------------------------------------------------------------
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[mPreviewView layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

//------------------------------------------------------------------------------
- (void)subjectAreaDidChange:(NSNotification *)notification
//------------------------------------------------------------------------------
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate

//------------------------------------------------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
//------------------------------------------------------------------------------
{
    if (error)
        NSLog(@"%@", error);
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}

//------------------------------------------------------------------------------
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
//------------------------------------------------------------------------------
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

//------------------------------------------------------------------------------
+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
//------------------------------------------------------------------------------
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

//------------------------------------------------------------------------------
+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
//------------------------------------------------------------------------------
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

//------------------------------------------------------------------------------
- (void)runStillImageCaptureAnimation
//------------------------------------------------------------------------------
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[mPreviewView layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[mPreviewView layer] setOpacity:1.0];
        }];
    });
}

//------------------------------------------------------------------------------
- (void)checkDeviceAuthorizationStatus
//------------------------------------------------------------------------------
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

//------------------------------------------------------------------------------
- (void)calendarButtonPressed
//------------------------------------------------------------------------------
{
    DataViewController *dataViewController= [[DataViewController alloc] init];
    [self.navigationController pushViewController:dataViewController animated:YES];
}

//------------------------------------------------------------------------------
- (void)profileButtonPressed
//------------------------------------------------------------------------------
{
    ProfileViewController *profileViewController= [[ProfileViewController alloc] init];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
