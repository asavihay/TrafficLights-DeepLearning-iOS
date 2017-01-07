//
//  ViewController.h
//  CaffeApp
//
//  Created by Takuya Matsuyama on 7/11/15.
//  Copyright (c) 2015 Takuya Matsuyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Classifier.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *lightImage;

@end

