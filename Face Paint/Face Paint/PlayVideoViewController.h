//
//  PlayVideoViewController.h
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h> // UTCoreTypes.h is no more.
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id )delegate;

@end
