//
//  MergeVideoViewController.h
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h> // Deprecated
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>

@interface MergeVideoViewController : ViewController {
    BOOL isSelectingAssetOne;
}

@property (nonatomic, strong) AVAsset *firstAsset;
@property (nonatomic, strong) AVAsset *secondAsset;
@property (nonatomic, strong) AVAsset *audioAsset;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;
-(void)exportDidFinish:(AVAssetExportSession *)session;

@end
