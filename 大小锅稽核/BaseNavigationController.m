//
//  BaseNavigationController.m
//  大小锅稽核
//
//  Created by yesdgq on 2019/4/1.
//  Copyright © 2019 Yesdgq. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 返回箭头颜色
    [self.navigationBar setTintColor:[UIColor blackColor]];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] init];
    backBtn.title = @"返回";
    self.navigationItem.backBarButtonItem = backBtn;
    // title颜色
    self.navigationBar.barStyle = UIBarStyleDefault;
}



@end
