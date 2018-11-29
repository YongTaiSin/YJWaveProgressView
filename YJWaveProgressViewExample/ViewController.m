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

    CGFloat size = 300;
    YJWaveProgressView *waveView = [[YJWaveProgressView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-size)/2, 0, size, size)];
    waveView.center = self.view.center;
    waveView.waveLength = size*5/3;
    waveView.waterColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:1];
    waveView.waterBgColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:0.6];
    waveView.descriptionText = @"汽车当前电量";
    waveView.progress = 0.8;
    [self.view addSubview:waveView];
}


@end
