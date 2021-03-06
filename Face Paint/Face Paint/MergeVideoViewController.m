//
//  MergeVideoViewController.m
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "MergeVideoViewController.h"

@interface MergeVideoViewController () <MPMediaPickerControllerDelegate>

- (IBAction)loadAssetOne:(id)sender;
- (IBAction)loadAssetTwo:(id)sender;
- (IBAction)loadAudio:(id)sender;
- (IBAction)mergeAndSave:(id)sender;

@end

@implementation MergeVideoViewController

//@synthesize firstAsset, secondAsset, audioAsset, activityView;

- (void)viewDidLoad {
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    // 1. Validation
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == Nil)) {
        return NO;
    }
    // 2. Create image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    // 3. Display image picker
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    // 1. Get media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 2. Dismiss image picker
    [self dismissViewControllerAnimated:NO completion:nil];
    // 3. Handle video selection
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        if (isSelectingAssetOne) {
            NSLog(@"Video One Loaded");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video One Loaded" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:continueButton];
            [self presentViewController:alert animated:YES completion:nil];
            self.firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            
        }
        else {
            NSLog(@"Video Two Loaded");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video Two Loaded" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:continueButton];
            [self presentViewController:alert animated:YES completion:nil];
            self.secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
}



- (IBAction)loadAssetOne:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Saved Album Found" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        isSelectingAssetOne = TRUE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAssetTwo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Saved Album Found" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:Nil];
    }
    else {
        isSelectingAssetOne = FALSE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAudio:(id)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    // mediaPicker.delegate = self had an error because MPMediaPickerControllerDelegate needed to be added.
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    // The above code creates a new MPMediaPickerController instance and displats it as a modal view controller
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

// Delegate method needed to choose the audio item
-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    NSArray *selectedSong = [mediaItemCollection items];
    if ([selectedSong count] > 0) {
        MPMediaItem *songItem = [selectedSong objectAtIndex:0];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        self.audioAsset = [AVAsset assetWithURL:songURL];
        NSLog(@"Audio Loaded");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Audio Loaded" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)mergeAndSave:(id)sender {
    
    if (self.firstAsset != nil && self.secondAsset != nil) {
        
        [self.activityView startAnimating];
        
        // 1. Create AVMutableComposition object. This will hold your
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        // 2. Video Track
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.firstAsset.duration) ofTrack:[[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.secondAsset.duration) ofTrack:[[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        // 2.1 Create AVMutableVideoCompositionInstruction
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.firstAsset.duration, self.secondAsset.duration));
        
        // 2.2 Create an AVMutableVideoCompositionLayerInstruction for the first track
        AVMutableVideoCompositionLayerInstruction *firstLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *firstAssetTrack = [[self.firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation firstAssetOrientation_ = NO; // What is with the underscore?
        BOOL isFirstAssetPortrait_ = NO;
        CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
        
        if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0) {
            firstAssetOrientation_ = UIImageOrientationRight;
            isFirstAssetPortrait_ = YES;
        }
        if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 1.0) {
            firstAssetOrientation_ = UIImageOrientationLeft;
            isFirstAssetPortrait_ = YES;
        }
        if (firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0) {
            firstAssetOrientation_ = UIImageOrientationUp;
        }
        if (firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {
            firstAssetOrientation_ = UIImageOrientationDown;
        }
        
        [firstLayerInstruction setTransform:self.firstAsset.preferredTransform atTime:kCMTimeZero];
        // Setting opacity at end of video or else it'll look bad with the freeze frame at completion
        [firstLayerInstruction setOpacity:0.0 atTime:self.firstAsset.duration];
        
        AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        AVAssetTrack *secondAssetTrack = [[self.secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation secondAssetOrientation_ = UIImageOrientationUp;
        BOOL isSecondAssetPortrait_ = NO;
        CGAffineTransform secondTransform = secondAssetTrack.preferredTransform;
        
        if (secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0) {
            secondAssetOrientation_ = UIImageOrientationRight;
            isSecondAssetPortrait_ = YES;
        }
        if (secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0) {
            secondAssetOrientation_ = UIImageOrientationLeft;
            isSecondAssetPortrait_ = YES;
        }
        if (secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {
            secondAssetOrientation_ = UIImageOrientationUp;
        }
        if (secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0) {
            secondAssetOrientation_ = UIImageOrientationUp;
        }
        [secondlayerInstruction setTransform:self.secondAsset.preferredTransform atTime:self.firstAsset.duration];
        
        // 2.4 Add Instructions
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstLayerInstruction, secondlayerInstruction, nil];
        AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition videoComposition];
        mainComposition.instructions = [NSArray arrayWithObject:mainInstruction];
        mainComposition.frameDuration = CMTimeMake(1, 30);
        
        CGSize naturalSizeFirst, naturalSizeSecond;
        if (isFirstAssetPortrait_) {
            naturalSizeFirst = CGSizeMake(firstAssetTrack.naturalSize.height, firstAssetTrack.naturalSize.width);
        }
        else {
            naturalSizeSecond = firstAssetTrack.naturalSize;
        }
        if (isSecondAssetPortrait_) {
            naturalSizeSecond = CGSizeMake(secondAssetTrack.naturalSize.height, secondAssetTrack.naturalSize.width);
        }
        else {
            naturalSizeSecond = secondAssetTrack.naturalSize;
        }
        
        float renderWidth, renderHeight;
        if (naturalSizeFirst.width > naturalSizeSecond.width) {
            renderWidth = naturalSizeFirst.width;
        }
        else {
            renderWidth = naturalSizeSecond.height;
        }
        mainComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
        
        // 3. Audio Track
        if (self.audioAsset != nil) {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.firstAsset.duration, self.secondAsset.duration)) ofTrack:[[self.audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        
    // 4. Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
    // 5. Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mainComposition;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
    }
}

-(void)exportDidFinish:(AVAssetExportSession *)session {
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        
        NSURL *outputURL = session.outputURL;
        
        __block PHObjectPlaceholder *placeholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
            placeholder = [createAssetRequest placeholderForCreatedAsset];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Video Saved" message:@"Saved to Photo Album" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    
                }
                else {

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Video Saving Failed" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    }
    
    self.audioAsset = nil;
    self.firstAsset = nil;
    self.secondAsset = nil;
    [self.activityView stopAnimating];
}


@end
