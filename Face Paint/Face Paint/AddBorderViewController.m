//
//  AddBorderViewController.m
//  Face Paint
//
//  Created by Bao Tran on 6/23/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "AddBorderViewController.h"

@interface AddBorderViewController ()

@end

@implementation AddBorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generate:(id)sender {
    [self videoOutput];
}


// This method creates a colored image matching the provided size by using standard drawing functions and then returns it.
- (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGRect)imageSize {
    
    CGRect rect = imageSize;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0); // Does it begin to take in the current image in view?
    [color setFill]; // Setfill from where?
    UIRectFill(rect); // Fill with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}


- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size {
    
    UIImage *borderImage = nil;
    
    if (_colorSegment.selectedSegmentIndex == 0) {
        borderImage = [self imageWithColor:[UIColor blueColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    } else if (_colorSegment.selectedSegmentIndex == 1) {
        borderImage = [self imageWithColor:[UIColor greenColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
    }
    
    // AVVideoCompositionCoreAnimationTool - Core Animation class handles video post-processing, needs **three** CALayer objects for video composition. 1. Parent layer, 2. background layer and 3. video layer.
    
    // Background layer - sets background layer using colored image
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setContents:(id)[borderImage CGImage]];
    backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [backgroundLayer setMasksToBounds:YES];
    NSLog(@"backgroundLayer:%@", NSStringFromCGRect(backgroundLayer.frame));

    
    self.widthBar.minimumValue = 5.0;
    self.widthBar.maximumValue = 10.0;
    // Video Layer - holds the video and sets the origin to the width of bar, then truncates the video frame to double with the width of the video to fit into space
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(self.widthBar.value, self.widthBar.value, size.width-(self.widthBar.value*2), size.height-(self.widthBar.value*2));
    NSLog(@"videoLayer.frame:%@", NSStringFromCGRect(videoLayer.frame));

    
    // Parent Layer - parent layer holds both the background later and the video layer. *This layer is rendered full size
    CALayer *parentLayer = [CALayer layer];
    
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    NSLog(@"parentLayer.frame:%@", NSStringFromCGRect(parentLayer.frame));
    [parentLayer addSublayer:backgroundLayer];
    [parentLayer addSublayer:videoLayer];
    // Order of layer matters, background has to be added BEFORE the video layer. If you mix it up, you will get a beautiful solid color background.
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    // AVVideoCompositionCoreAnimationTool needs to point to where the output should go - videoLayer - and where the input is coming from - parentLayer.
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
