//
//  RecordVideoViewController.m
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "RecordVideoViewController.h"

@interface RecordVideoViewController ()

- (IBAction)recordAndPlay:(id)sender;

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)startCameraControllerFromViewController:(UIViewController *)controller usingDelegate:(id )delegate {
    
    // 1. Validations
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    // 2.Get image picker
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allow the user to choose movie capture
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving and scaling pictures, or for trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    // 3. Display image picker
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    // Handle a movie capture
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        // /private/var/mobile/Containers/Data/Application/B9E03C92-F66B-4398-9363-5E2626C8BE35/tmp/capture-T0x12fd047b0.tmp.iEpw5K/capturedvideo.MOV
        // The above method works because it gets rid of file:// before the path.
        
//        NSString *moviePath = [info valueForKeyPath:UIImagePickerControllerMediaURL];
        // file:///private/var/mobile/Containers/Data/Application/47490513-99D8-4B38-BB2E-E18E31EAC414/tmp/capture-T0x13750b150.tmp.dXixPl/capturedvideo.MOV
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }

}

// The method is alert the viewer whether the user's video was saved successfully
-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Video Saving Failed" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertController *savedAlert = [UIAlertController alertControllerWithTitle:@"Video Saved" message:@"Saved To Photo Album" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    if (error) {
        [errorAlert addAction:continueButton];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else {
        [savedAlert addAction:continueButton];
        [self presentViewController:savedAlert animated:YES completion:nil];

    }
    
}

- (IBAction)recordAndPlay:(id)sender {
    
    [self startCameraControllerFromViewController:self usingDelegate:self];
    
}

@end
