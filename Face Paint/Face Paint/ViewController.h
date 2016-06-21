//
//  ViewController.h
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) AVAsset *videoAsset;

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;
-(void)exportDidFinish:(AVAssetExportSession *)session;
-(void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;
-(void)videoOutput;

@end

