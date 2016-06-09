//
//  PlayVideoViewController.m
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()

- (IBAction)playVideo:(id)sender;

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// This method allows you to pick media from your library. It won't play the media! Must implement another method for that
-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id )delegate {
    // 1. This validates the controller, delegate to make sure it is not nil
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil)) {
        
        NSLog(@"Either Delegate is nil, controller is nil or no sourceTypeAvailable");
        
        return NO;
        
    }
    // 2. Once validated, it gets the image picker. Using the UIImagePickerControllerDelegate
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
    // Hides the controls for moving and scaling pictures, or for trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    
    // 3. Displays the image picker controller
//    [controller presentModalViewController:(nonnull UIViewController *) animated:<#(BOOL)#>]; // Deprecated.
    [controller presentViewController:mediaUI animated:NO completion:nil];
    
    return YES;
}

// This method allows you to pick and verify the media type.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
   
    // 1. Gets the media type so you can verify later on that the selected media is a video.
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // 2. Dismisses the image picker so that it’s no longer displayed on screen.
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // Handle the movie capture
    
    if (CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
    // 3. Verifies that the selected media is a video, and then creates an instance of MPMoviePlayerViewController to play it.
//        AVPlayer *aMovie = [[AVPlayer alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        AVPlayerViewController *movieViewController = [[AVPlayerViewController alloc] init];
        movieViewController.player = [[AVPlayer alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        [self presentViewController:movieViewController animated:YES completion:nil];
        
        // The below code is deprecated.
//        MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//        [self presentViewController:theMovie animated:YES completion:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:movieViewController];
        
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallBack:) name:AVPlayerItemDidPlayToEndTimeNotification object:movieViewController];
    }
    
}

-(void)myMovieFinishedCallBack:(NSNotification *)notification {

//  The below method is deprecated.
//  [self dismissModalViewControllerAnimated: YES];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playVideo:(id)sender {
    
    [self startMediaBrowserFromViewController:self usingDelegate:self];
    // The "Play Video" button will poen the UIImagePickerController, this allows the user to select a video from the media Library.
}
@end
