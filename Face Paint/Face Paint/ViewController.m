//
//  ViewController.m
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initialization
    }
    return self;
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    // 1. Validations
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
    // 2. Get image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
    // Hides the controls form moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    
    mediaUI.delegate = self;
    // When delegate is not set, exportDidFinish: does NOT get called.

    
    // 3. Display image picker
    [controller presentViewController:mediaUI animated:YES completion:^{
        NSLog(@"begin mediaUI picker");
    }];
    return YES;
}

//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 1. Get media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"What is mediaType:%@", mediaType);
    
    // 2. Dissmiss image picker
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"mediaUI did finish picking media");
    }];
    
    // 3. Handle Video Selection
    // What the heck is __bridge_retained CFStringRef?
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        self.videoAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video Asset Loaded" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [alert addAction:continueButton];
            [self presentViewController:alert animated:YES completion:nil];
        
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // no-op - override this method in the subclass
}

- (void)videoOutput {
    // 1. Early exit if there is no video file selected
    if (!self.videoAsset) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please load a video asset first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:continueButton];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 2. Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instaces.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3. Video Track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration) ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    // 3.1 Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    
    // 3.2 Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    UIImageOrientation videoAssetOrientation_ = UIImageOrientationUp;
    
    BOOL isVideoAssetPortrait_ = NO;
    
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ = UIImageOrientationUp;
    }
    if (videoTransform.a == 1-.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    
    [videoLayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    // 3.3 Add Instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videoLayerInstruction, nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if (isVideoAssetPortrait_) {
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    }
    else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 4. Get Path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo-%d.mov", arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 5. Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession *)session {
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        
        __block PHObjectPlaceholder *placeholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
            placeholder = [createAssetRequest placeholderForCreatedAsset];
        } completionHandler:^(BOOL success, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // AlertViewController kept crashing because it was in the another thread, had to go back to main thread
                
                if (error) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a error saving the video" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Video saving success!" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
            });
            
        }];
    }
}



@end
