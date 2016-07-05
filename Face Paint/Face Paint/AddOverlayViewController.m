//
//  AddOverlayViewController.m
//  Face Paint
//
//  Created by Bao Tran on 6/23/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "AddOverlayViewController.h"

@interface AddOverlayViewController ()

@end

@implementation AddOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size {
    
    // 1. Set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = nil;
    if (_frameSelectControl.selectedSegmentIndex == 0) {
        overlayImage = [UIImage imageNamed:@"overlay1.png"];
    }
    else if (_frameSelectControl.selectedSegmentIndex == 1) {
        overlayImage = [UIImage imageNamed:@"overlay2.png"];
    }
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 2. Set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3. Apply overlay
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

- (IBAction)loadAsset:(id)sender {
}

- (IBAction)generateOutput:(id)sender {
}
@end
