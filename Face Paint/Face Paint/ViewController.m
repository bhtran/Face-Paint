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
    [self createView];

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

-(void)createView {
    
    UIButton *selectAndPlayButton = [UIButton buttonWithType:(UIButtonTypeCustom)];

    UIView *superView = self.view;
    
    selectAndPlayButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superView addSubview:selectAndPlayButton];
    
    [selectAndPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(superView.mas_height).with.multipliedBy(.20);
        make.width.equalTo(superView.mas_width).with.multipliedBy(.20);
        make.centerX.equalTo(superView.mas_centerX);
        make.centerY.equalTo(superView.mas_centerY);
        
    }];
    
    selectAndPlayButton.layer.borderWidth = 2;
    selectAndPlayButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
}


@end
