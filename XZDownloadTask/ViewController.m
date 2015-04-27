//
//  ViewController.m
//  XZDownloadTask
//
//  Created by xiazer on 15/4/17.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "ViewController.h"
#import "SingleDownloadViewController.h"
#import "MultDownloadViewController.h"

////定义屏幕高度
//#define ScreenHeight [UIScreen mainScreen].bounds.size.height
////定义屏幕宽度
//#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"后台下载Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 100, ScreenWidth, 40);
    [btn addTarget:self action:@selector(singleDownloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor blackColor];
    NSString *titStr = @"单任务下载";
    [btn setTitle:titStr forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
    [self.view addSubview:btn];

    UIButton *btnMult = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMult.frame = CGRectMake(0, 160, ScreenWidth, 40);
    [btnMult addTarget:self action:@selector(multDownloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btnMult.backgroundColor = [UIColor blackColor];
    NSString *titStrMult = @"多任务下载";
    [btnMult setTitle:titStrMult forState:UIControlStateNormal];
    btnMult.tintColor = [UIColor whiteColor];
    [self.view addSubview:btnMult];
}

- (void)singleDownloadBtnClick:(id)sender {
    SingleDownloadViewController *vc = [[SingleDownloadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)multDownloadBtnClick:(id)sender {
    MultDownloadViewController *vc = [[MultDownloadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
