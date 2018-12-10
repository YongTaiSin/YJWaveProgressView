//
//  YJWaveProgressView.h
//  YJWaveProgressViewDemo
//
//  Created by Jeremiah on 2018/11/28.
//  Copyright © 2018 Jeremiah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,YJWaveScaleStyle){
    /// 默认
    YJWaveScaleStyle_Default,
    /// 时钟
    YJWaveScaleStyle_Clock,
};
@interface YJWaveProgressView : UIView

/** 进度 (0 ~ 1) */
@property (nonatomic, assign) CGFloat progress;

/** 波长 默认是宽度的2倍 */
@property (nonatomic, assign) CGFloat waveLength;

/** 振幅 默认为6 */
@property (nonatomic, assign) CGFloat amplitude;

/** 波纹移动速度 默认为8 */
@property (nonatomic, assign) CGFloat waveSpeed;

/** 波纹上升速度 默认为0.85 */
@property (nonatomic, assign) CGFloat waveGrowth;

/** 水波颜色 */
@property (nonatomic, strong) UIColor *waterColor;

/** 水波的背景色 */
@property (nonatomic, strong) UIColor *waterBgColor;

/** 文字颜色 */
@property (nonatomic, strong) UIColor *textColor;

/** 描述文字 */
@property (nonatomic, copy  ) NSString *descriptionText;

/** 描述文字字体 */
@property (nonatomic, strong) UIFont *descriptionFont;

/** 数字字体 */
@property (nonatomic, strong) UIFont *numberFont;

/** 百分比字体 */
@property (nonatomic, strong) UIFont *percentFont;

/** 描述属性文字 */
@property (nonatomic, copy  ) NSAttributedString *descriptionAttributedText;

/** 百分比属性文本 */
@property (nonatomic, copy  ) NSAttributedString *percentageAttributedText;

/** 是否显示刻度表盘 默认为NO */
@property (nonatomic, assign) BOOL showScale;

/** 刻度到圆形水波的距离 默认为10 */
@property (nonatomic, assign) CGFloat waveMargin;

/** 刻度长度 默认为10 */
@property (nonatomic, assign) CGFloat scaleLength;

/** 刻度宽度 默认为2 */
@property (nonatomic, assign) CGFloat scaleWidth;

/** 刻度的个数 默认为100 */
@property (nonatomic, assign) CGFloat scaleCount;

/** 刻度线背景色 */
@property (nonatomic, strong) UIColor *scaleBgColor;

/** 刻度线颜色 */
@property (nonatomic, strong) UIColor *scaleColor;

/** 刻度的样式 */
@property (nonatomic, assign) YJWaveScaleStyle scaleStyle;

/** 是否允许重力感应 默认为NO */
@property (nonatomic, assign) BOOL allowCoreMotion;

//  开始波动
- (void)startWave;
//  停止波动
- (void)stopWave;

@end

@interface YJWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;

@end
