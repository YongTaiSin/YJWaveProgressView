# YJWaveProgressView
一款圆形水波进度控件，高度可定制开发，支持自动布局
<p align="center">
<a href="https://github.com/mcyj1314/YJWaveProgressView"><img src="https://img.shields.io/badge/platform-iOS%208.0%2B-ff69b5152950834.svg"></a>
<a href="https://github.com/mcyj1314/YJWaveProgressView"><img src="https://img.shields.io/cocoapods/v/YJWaveProgressView.svg?style=flat"></a>
<a href="https://github.com/mcyj1314/YJWaveProgressView/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
</p>

## Demo
<img src="https://github.com/mcyj1314/YJWaveProgressView/blob/master/screenshots/screenshot.gif" alt="">
   
## Installation
* Installation with CocoaPods：`#pod 'YJWaveProgressView'`
* Manual import：
    * Drag All files in the `YJWaveProgressView` folder to project
    * Import the main file：`#import "YJWaveProgressView.h"`
    
## Usage
```objc
    CGFloat size = 300;
    YJWaveProgressView *waveView = [[YJWaveProgressView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-size)/2, 0, size, size)];
    waveView.center = self.view.center;
    waveView.waveLength = size*5/3;
    waveView.waterColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:1];
    waveView.waterBgColor = [UIColor colorWithRed:107/255.0 green:194/255.0 blue:53/255.0 alpha:0.6];
    waveView.descriptionText = @"汽车当前电量";
    waveView.progress = 0.8;
    [self.view addSubview:waveView];
```

## Remind
* ARC
* iOS>=8.0
* iPhone \ iPad screen anyway

# Contact me
- Email:  jellybilly@foxmail.com

# License
YJWaveProgressView is available under the MIT license. See the LICENSE file for more info.
