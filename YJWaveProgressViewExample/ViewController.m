//
//  ViewController.m
//  YJWaveProgressViewExample
//
//  Created by 杨健 on 2018/11/29.
//  Copyright © 2018 Jeremiah. All rights reserved.
//

#import "ViewController.h"
#import "YJWaveProgressView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.165 green:0.659 blue:0.980 alpha:1.00];
    CGFloat size = 300;
    YJWaveProgressView *waveView = [[YJWaveProgressView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-size)/2, 0, size, size)];
    waveView.center = self.view.center;
    // 水波颜色
    waveView.waterColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:1];
    // 水波背景颜色
    waveView.waterBgColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:0.6];
    // 设置描述文字
    waveView.descriptionText = @"汽车当前电量";
    // 显示刻度
    waveView.showScale = YES;
    // 时钟刻度样式
    waveView.scaleStyle = YJWaveScaleStyle_Clock;
    // 允许重力感应
    waveView.allowCoreMotion = YES;
    // 设置进度
    waveView.progress = 0.6;
    [self.view addSubview:waveView];
}

@end
