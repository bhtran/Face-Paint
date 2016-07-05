//
//  AddTiltViewController.h
//  Face Paint
//
//  Created by Bao Tran on 6/23/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "ViewController.h"

@interface AddTiltViewController : ViewController
- (IBAction)loadAsset:(id)sender;
- (IBAction)generateAsset:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end
