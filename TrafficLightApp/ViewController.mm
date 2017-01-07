//
//  ViewController.m
//  CaffeApp
//
//  Created by Avihay Assouline
//  Copyright (c) 2016 Avihay Assouline. All rights reserved.
//

#import "ViewController.h"

using namespace std;

@interface ViewController ()
{
    Classifier *classifier;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    bool isProcessing;
}
@end

@implementation ViewController

NSDictionary* const labelToImage = @{
                                     @"background": @"noLight.png",
                                     @"green": @"greenLight.png",
                                     @"red": @"redLight.png"
                                     };

//////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *netDefinition = [NSBundle.mainBundle pathForResource:@"deploy"
                                                         ofType:@"prototxt"
                                                    inDirectory:@"model"];

    NSString *netWeights = [NSBundle.mainBundle pathForResource:@"model"
                                                           ofType:@"caffemodel"
                                                      inDirectory:@"model"];
    
    NSString *datasetMean = [NSBundle.mainBundle pathForResource:@"mean"
                                                          ofType:@"binaryproto"
                                                     inDirectory:@"model"];
    
    
    NSString *netLabels = [NSBundle.mainBundle pathForResource:@"labels"
                                                        ofType:@"txt"
                                                   inDirectory:@"model"];
    
    string net_definition = string([netDefinition UTF8String]);
    string net_weights = string([netWeights UTF8String]);
    string dataset_mean = string([datasetMean UTF8String]);
    string net_labels = string([netLabels UTF8String]);

    classifier = new Classifier(net_definition,
                                net_weights,
                                dataset_mean,
                                net_labels);
    
    [self setupCaptureSession];
    
}

//////////////////////////////////////////////////////////////////////

- (void)predictWithImage:(UIImage*)image;
{
    if (!image)
        return;
    
    cv::Mat src_img, bgra_img;
    UIImageToMat(image, src_img);
    
    // needs to convert to BGRA because the image loaded from UIImage is in RGBA
    cv::resize(src_img, src_img, cv::Size(224, 224));
    cv::cvtColor(src_img, bgra_img, CV_RGBA2BGR);
    
    vector<Prediction> result = classifier->Classify(bgra_img, 3);
    
    for (vector<Prediction>::iterator it = result.begin(); it != result.end(); ++it) {
        NSString* mylabel = [NSString stringWithUTF8String:it->first.c_str()];
        NSNumber* probability = [NSNumber numberWithFloat:it->second];
        if (it == result.begin() && probability.floatValue > 0.6) {
            _lightImage.image = [UIImage imageNamed:[labelToImage valueForKey:mylabel]];
        }
    }
}

//////////////////////////////////////////////////////////////////////

// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    captureSession = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Find a suitable AVCaptureDevice
    NSArray *cameras=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [cameras objectAtIndex:0];
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input)
    {
        return;
    }
    [captureSession addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [captureSession addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // Setup the display layer
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer.frame = self.view.bounds; // Assume you want the preview layer to fill the view.
    previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    [captureSession startRunning];
}


//////////////////////////////////////////////////////////////////////

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Using a boolean flag as a patch to process the latest
    // frame when running on device. This could have been solved much
    // cleaner but with a bit more code - We'll keep it this way
    if (isProcessing)
        return;
    
    UIImage *im = [self imageFromSampleBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        isProcessing = YES;
        [self predictWithImage:im];
        isProcessing = NO;
    });
}

//////////////////////////////////////////////////////////////////////

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    //NSLog(@"imageFromSampleBuffer: called");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

//////////////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////////////

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

//////////////////////////////////////////////////////////////////////

-(BOOL)shouldAutorotate {
    return NO;
}

@end

