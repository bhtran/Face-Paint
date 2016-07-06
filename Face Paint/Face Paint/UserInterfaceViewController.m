//
//  UserInterfaceViewController.m
//  Face Paint
//
//  Created by Bao Tran on 7/6/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "UserInterfaceViewController.h"

@interface UserInterfaceViewController ()

@end

@implementation UserInterfaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
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

-(void)createView {
    
    UIButton *selectAndPlayButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *recordAndSaveButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *mergeAndSaveButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *overlayButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *subtitleButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *animationButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *tiltButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    UIButton *borderButton = [UIButton buttonWithType:(UIButtonTypeCustom)];

    //    UIView *self.view = self.view;
    
    [self.view addSubview:selectAndPlayButton];
    [self.view addSubview:recordAndSaveButton];
    [self.view addSubview:mergeAndSaveButton];
    [self.view addSubview:overlayButton];
    [self.view addSubview:subtitleButton];
    [self.view addSubview:animationButton];
    [self.view addSubview:tiltButton];
    [self.view addSubview:borderButton];

    [recordAndSaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(20);
        make.right.equalTo(selectAndPlayButton.mas_left).with.offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
    
    [selectAndPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(recordAndSaveButton.mas_right).with.offset(20);
        make.right.equalTo(mergeAndSaveButton.mas_left).with.offset(-20);
        make.bottom.equalTo(recordAndSaveButton.mas_bottom);
    }];
    
    [mergeAndSaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.bottom.equalTo(recordAndSaveButton.mas_bottom);
        
    }];
    
//    [overlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo()
//    }];
//    
    recordAndSaveButton.layer.borderWidth = 2;
    mergeAndSaveButton.layer.borderWidth = 2;
    selectAndPlayButton.layer.borderWidth = 2;

    recordAndSaveButton.layer.borderColor = [[UIColor blueColor] CGColor];
    mergeAndSaveButton.layer.borderColor = [[UIColor redColor] CGColor];
    selectAndPlayButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    // Gradient Background
    UIColor *topColor = [UIColor colorWithRed:222.0f/255.0f green:222.0f/255.0f blue:222.0f/255.0f alpha:.85];
    UIColor *bottomColor = [UIColor colorWithRed:255.0f/255.0f green:251.0f/255.0f blue:232.0f/255.0f alpha:.20];
    
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = self.view.bounds;
    
    [self.view.layer insertSublayer:theViewGradient atIndex:0];

    self.view.backgroundColor = [UIColor colorWithRed:84.0f/255.0f green:84.0f/255.0f blue:84.0f/255.0f alpha:1];

}


@end
