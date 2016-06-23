//
//  AddBorderViewController.h
//  Face Paint
//
//  Created by Bao Tran on 6/23/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AddBorderViewController : ViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;

@property (weak, nonatomic) IBOutlet UISlider *widthBar;

- (IBAction)loadAsset:(id)sender;
- (IBAction)generate:(id)sender;

@end
