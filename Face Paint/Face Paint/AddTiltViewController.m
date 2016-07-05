//
//  AddTiltViewController.m
//  Face Paint
//
//  Created by Bao Tran on 6/23/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "AddTiltViewController.h"

@interface AddTiltViewController ()

@end

@implementation AddTiltViewController

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
    // 1. Layer Setup
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    [parentLayer addSublayer:videoLayer];
    
    // 2. Set up the transform
    CATransform3D identityTransform = CATransform3DIdentity;
    
    // 3. Pick the direction
    if (_segmentControl.selectedSegmentIndex == 0) {
        identityTransform.m34 = 1.0 / 1000;
    }
    else if (_segmentControl.selectedSegmentIndex == 1) {
        identityTransform.m34 = 1.0 / -10000;
    }
    
    // 4. Rotate
    videoLayer.transform = CATransform3DRotate(identityTransform, M_PI/6.0, 1.0f, 0.0f, 0.0f);
    
    // 5. Composition
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

- (IBAction)loadAsset:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)generateAsset:(id)sender {
    [self videoOutput];
}
@end
