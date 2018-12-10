# YJWaveProgressView
一款圆形水波进度控件，高度可定制开发，支持自动布局
<p align="center">
<a href="https://github.com/mcyj1314/YJWaveProgressView"><img src="https://img.shields.io/badge/platform-iOS%208.0%2B-ff69b5152950834.svg"></a>
<a href="https://github.com/mcyj1314/YJWaveProgressView"><img src="https://img.shields.io/cocoapods/v/YJWaveProgressView.svg?style=flat"></a>
<a href="https://github.com/mcyj1314/YJWaveProgressView/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
</p>

## Demo

<div class="wrap">
<img src="https://github.com/mcyj1314/YJWaveProgressView/blob/master/screenshots/%E6%B0%B4%E6%B3%A2.gif" alt="">
<img src="https://github.com/mcyj1314/YJWaveProgressView/blob/master/screenshots/%E5%B8%A6%E5%88%BB%E5%BA%A6.gif" alt="">
<img src="https://github.com/mcyj1314/YJWaveProgressView/blob/master/screenshots/%E9%87%8D%E5%8A%9B%E6%84%9F%E5%BA%94.gif" alt="">
</div>
   
## Installation
* Installation with CocoaPods：`pod 'YJWaveProgressView'`
* Manual import：
    * Drag All files in the `YJWaveProgressView` folder to project
    * Import the main file：`#import "YJWaveProgressView.h"`
    
## Usage
✨✨ 支持自动布局 ✨✨
<pre><code>
    YJWaveProgressView *waveView = [[YJWaveProgressView alloc]init];
    // 设置水波颜色
    waveView.waterColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:1];
    // 设置水波背景颜色
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
    waveView.progress = 0.8;
    [self.view addSubview:waveView];
    [waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
</code></pre>

## Update
- **2018.12.10**
添加新功能：新增刻度盘显示、支持重力感应

## Remind
* ARC
* iOS>=8.0
* iPhone \ iPad screen anyway

# Contact me
- Email:  jellybilly@foxmail.com

# License
YJWaveProgressView is available under the MIT license. See the LICENSE file for more info.
