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
    
    //    UIView *self.view = self.view;
    
    [self.view addSubview:selectAndPlayButton];
    [self.view addSubview:recordAndSaveButton];
    [self.view addSubview:mergeAndSaveButton];
    
    [recordAndSaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(30);
        make.left.equalTo(self.view.mas_left).with.offset(30);
        make.right.equalTo(mergeAndSaveButton.mas_left).with.offset(-30);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-30);
        
    }];
    [mergeAndSaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(30);
        make.right.equalTo(self.view.mas_right).with.offset(-30);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-30);
    }];
    
    recordAndSaveButton.layer.borderWidth = 2;
    recordAndSaveButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
    mergeAndSaveButton.layer.borderWidth = 2;
    mergeAndSaveButton.layer.borderColor = [[UIColor blackColor] CGColor];
}


@end
