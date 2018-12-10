//
//  YJWaveProgressView.m
//  YJWaveProgressViewDemo
//
//  Created by Jeremiah on 2018/11/28.
//  Copyright © 2018 Jeremiah. All rights reserved.
//
/*
 正弦型函数解析式：y=Asin（ωx+φ）+h
 各常数值对函数图像的影响：
 φ（初相位）：决定波形与X轴位置关系或横向移动距离（左加右减）
 ω：决定周期（最小正周期T=2π/|ω|）
 A：决定峰值（即纵向拉伸压缩的倍数）
 h：表示波形在Y轴的位置关系或纵向移动距离（上加下减）

 如果想绘制出来一条正弦函数曲线，可以沿着假想的曲线绘制许多个点，然后把点逐一用直线连在一起，如果点足够多，就可以得到一条满足需求的曲线，这也是一种微分的思想。而这些点的位置可以通过正弦函数的解析式求得。
 加入水波的峰值是1，周期是2π，初相位是0，h位移也是0。那么计算各个点的坐标公式就是y = sin(x);获得各个点的坐标之后，使用CGPathAddLineToPoint这个函数，把这些点逐一连成线，就可以得到最后的路径。

 如果想要得到一个动态的波纹,随着时间的变化,我们如果假定每个点的x位置没有变化,那么只要让其y随着时间有规律的变化就可以让人觉得是在有规律的动.需要注意UIKit的坐标系统y轴是向下延伸。
 如果想在0到2π这个距离显示2个完整的波曲线，那么周期就是π.如果每次增加π/4,则4s就会完成一个周期.
 如果想要在width上来宽度上展示2个周期的水波,则周期是waveWidth / 2, ω = 2 * M_PI / T
*/

#import "YJWaveProgressView.h"
#import <CoreMotion/CoreMotion.h>

@interface YJWaveProgressView()
{
    CGRect fullRect;            // 视图frame
    CGRect scaleRect;           // 刻度frame
    CGRect waveRect;            // 水波frame
    
    CGFloat currentPercent;     // 当前百分比，用于保存第一次显示时的动画效果
    CGFloat currentWavePointY;  // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    CGFloat offsetX;            // 波浪x位移
    
    float variable;             // 可变参数 更加真实 模拟波纹
    BOOL increase;              // 增减变化
    
    CGAffineTransform currentTransform;
}

/// 刷新定时器
@property (nonatomic, strong) CADisplayLink *displayLink;

/// 重力感应管理
@property (nonatomic, strong) CMMotionManager *motionManager;
/// 最新偏航角
@property (nonatomic) float motionLastYaw;

/// 水波背景层
@property (nonatomic, strong) CAShapeLayer *waveBackLayer;
/// 水波层
@property (nonatomic, strong) CAShapeLayer *waveLayer;

/// 刻度背景层
@property (nonatomic, strong) CAShapeLayer *scaleBackLayer;
/// 刻度层
@property (nonatomic, strong) CAShapeLayer *scaleLayer;
/// 左边刻度
@property (nonatomic, strong) CAShapeLayer *scaleLeftLayer;
/// 右边刻度
@property (nonatomic, strong) CAShapeLayer *scaleRightLayer;
/// 左边刻度遮罩
@property (nonatomic, strong) CAShapeLayer *scaleLeftMaskLayer;
/// 右边刻度遮罩
@property (nonatomic, strong) CAShapeLayer *scaleRightMaskLayer;

/// 文字
@property (nonatomic, strong) UILabel *textLb;

@end

@implementation YJWaveProgressView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        //初始化
        [self initialize];
        [self setupLayer];
    }
    
    return self;
}

- (void)dealloc{
    [self stopWave];
}

- (void)initialize
{
    // 进度
    _progress = 0.0;
    // 波长
    _waveLength = 0;
    // 振幅
    _amplitude = 6;
    // 移动速度
    _waveSpeed = 8;
    // 上升速度
    _waveGrowth = 0.85;
    
    // 是否显示刻度表
    _showScale = NO;
    // 刻度长度
    _scaleLength = 10;
    // 刻度宽度
    _scaleWidth = 2;
    // 刻度个数
    _scaleCount = 60;
    // 刻度到圆形水波的距离
    _waveMargin = 10;
    
    // 水波颜色
    _waterColor = [UIColor colorWithRed:0.325 green:0.392 blue:0.729 alpha:1.00];
    // 波浪背景填充色
    _waterBgColor = [UIColor colorWithRed:0.259 green:0.329 blue:0.506 alpha:1.00];
    
    // 刻度背景颜色
    _scaleBgColor = [UIColor colorWithRed:0.694 green:0.745 blue:0.867 alpha:1.00];
    // 刻度颜色
    _scaleColor = [UIColor colorWithRed:0.969 green:0.937 blue:0.227 alpha:1.00];
    
    // 文字颜色
    _textColor = [UIColor whiteColor];
    // 描述文字
    _descriptionText = @"";
    
    // 振幅变量
    variable = 1.6;
    // 增减变化
    increase = NO;
    // 移动距离
    offsetX = 0;
    
    // 最新偏航
    self.motionLastYaw = 0;
    
    [self configureDrawingRects];
}

- (void)setupLayer{
    // 添加刻度背景层
    [self.layer addSublayer:self.scaleBackLayer];
    // 添加刻度层
    [self.layer addSublayer:self.scaleLayer];
    [self.scaleLayer addSublayer:self.scaleLeftLayer];
    [self.scaleLayer addSublayer:self.scaleRightLayer];
    
    // 添加背景层
    [self.layer addSublayer:self.waveBackLayer];
    
    // 添加水波层
    [self.waveBackLayer addSublayer:self.waveLayer];
    
    // 添加文本
    [self addSubview:self.textLb];
}

- (void)configureDrawingRects
{
    CGFloat size = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat x = (self.bounds.size.width - size) / 2;
    CGFloat y = (self.bounds.size.height - size) / 2;
    fullRect = CGRectMake(x, y, size, size);
    scaleRect = fullRect;
    

    CGFloat offset = 0;
    if (_showScale) {
        offset = _waveMargin + _scaleLength;
    }
    waveRect = CGRectMake(x+offset,
                          y+offset,
                          fullRect.size.width - 2 * offset,
                          fullRect.size.height - 2 * offset);
}


#pragma mark - wave
// 动态更新水波
- (void)updateWave:(CADisplayLink *)displayLink {
    [self animateWave];
    [self updateWaveY];
    [self drawWave];
}

// 动态改变波形参数
- (void)animateWave
{
    if (increase) {
        variable += 0.01;
    }else{
        variable -= 0.01;
    }
    
    if (variable<=1) {
        increase = YES;
    }
    
    if (variable>=1.6) {
        increase = NO;
    }
    offsetX += _waveSpeed;
}

// 更新Y轴偏距的大小 直到达到目标偏距 让wave有一个匀速增长的效果
- (void)updateWaveY
{
    CGFloat targetY = waveRect.size.height - _progress * waveRect.size.height;
    if (currentWavePointY < targetY) {
        currentWavePointY += _waveGrowth;
        if (currentWavePointY>waveRect.size.height) {
            currentWavePointY=waveRect.size.height;
        }
    }
    if (currentWavePointY > targetY ) {
        currentWavePointY -= _waveGrowth;
        if (currentWavePointY<0) {
            currentWavePointY = 0;
        }
    }
}

// 开始波动
- (void)startWave {
    if (_displayLink&&!_displayLink.isPaused) {
        return;
    }
    //以屏幕刷新速度为周期刷新曲线的位置
    YJWeakProxy *proxy = [YJWeakProxy proxyWithTarget:self];
    _displayLink = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(updateWave:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    if (_allowCoreMotion) {
        //允许重力感应
        [self startGravity];
    }
}

// 停止波动
- (void)stopWave {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    [self stopGravity];
}

#pragma mark - motion
- (void)startGravity
{
    [self stopGravity];
    if ([self.motionManager isDeviceMotionAvailable]) {
        // to avoid using more CPU than necessary we use ``CMAttitudeReferenceFrameXArbitraryZVertical``
        typeof(self) __weak weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [weakSelf motionRefresh];
        }];
        
    }
}
- (void)stopGravity
{
    _motionLastYaw = 0;
    if ([_motionManager isDeviceMotionActive])
        [_motionManager stopDeviceMotionUpdates];
}
- (void)motionRefresh
{
    // compute the device yaw from the attitude quaternion
    // http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    
    // TODO improve the yaw interval (stuck to [-PI/2, PI/2] due to arcsin definition
    
    yaw *= -1;      // reverse the angle so that it reflect a *liquid-like* behavior
    
    if (_motionLastYaw == 0) {
        _motionLastYaw = yaw;
    }
    
    // 空间位置的四元数
    // kalman filtering
    static float q = 0.1;   // process noise
    static float s = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = _motionLastYaw;
    p = p + q;
    k = p / (p + s);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,-x);
    _waveLayer.affineTransform = newTransform;
    _motionLastYaw = x;
}

#pragma mark - private methods
/**
 *  格式化电量的Label的字体
 *
 *  @param percent 百分比
 *
 *  @return 电量百分比属性文本
 */
- (NSMutableAttributedString *)formatPercentage:(NSInteger)percent
{
    UIColor *textColor = _textColor;
    
    NSString *percentText = [NSString stringWithFormat:@"%ld%%",(long)percent];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:percentText];
    
    CGFloat numberFontSize = 60;
    CGFloat percentFontSize = 30;
    if (waveRect.size.width<180) {
        numberFontSize = 60*(waveRect.size.width/180);
        percentFontSize = 30*(waveRect.size.width/180);
    }
    UIFont *capacityNumberFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:numberFontSize];
    UIFont *capacityPercentFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:percentFontSize];
    if (_numberFont) {
        capacityNumberFont = _numberFont;
    }
    if (_percentFont) {
        capacityPercentFont = _percentFont;
    }
    NSRange numberRange = [percentText rangeOfString:[NSString stringWithFormat:@"%ld",(long)percent]];
    NSRange percentRange = [percentText rangeOfString:@"%"];
    [attrText addAttribute:NSFontAttributeName value:capacityNumberFont range:numberRange];
    [attrText addAttribute:NSFontAttributeName value:capacityPercentFont range:percentRange];
    [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, percentText.length)];
    
    return attrText;
}


/**
 *  格式化描述Label的字体
 *
 *  @param descriptionText 描述文字
 *
 *  @return 描述属性文本
 */
- (NSMutableAttributedString *)formatDescription:(NSString*)descriptionText
{
    UIColor *textColor = _textColor;
    
    CGFloat descriptionFontSize = 14;
    if (waveRect.size.width<150) {
        descriptionFontSize = 14*(waveRect.size.width/150);
    }
    UIFont *font = [UIFont systemFontOfSize:descriptionFontSize];
    if (_descriptionFont) {
        font = _descriptionFont;
    }
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:descriptionText];
    [attrText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, descriptionText.length)];
    [attrText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, descriptionText.length)];
    
    return attrText;
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawBezierPath];
}

- (void)drawBezierPath{
    if (_showScale) {
        [self drawScaleBackground];
        [self drawScale];
    }
    [self drawWaveBackground];
    [self drawWave];
    [self drawText];
}

/**
 画刻度盘
 
 @param scaleColor 刻度颜色
 @param isLeft 是否是左边的刻度盘
 @return 刻度layer数组
 */
- (NSArray <CAShapeLayer *>*)drawScaleWithColor:(UIColor *)scaleColor isLeft:(BOOL)isLeft{
    NSMutableArray *scaleArr = [NSMutableArray array];
    int section = _scaleCount / 2;
    int count = section + 1;
    CGFloat perAngle = M_PI / section;
    CGPoint centerPoint = CGPointMake(scaleRect.size.width / 2, scaleRect.size.height / 2);
    if (!isLeft) { //右边的圆心坐标
        centerPoint = CGPointMake(0, scaleRect.size.height / 2);
    }
    CGFloat radius = (scaleRect.size.width - _scaleLength) / 2;
    // 我们需要计算出每段弧线的起始角度和结束角度
    //角(弧度) = 弧长/半径
    for (int i = 0; i< count; i++) {
        CGFloat startAngel = 0;
        if (isLeft) {
            startAngel = M_PI_2 + perAngle * i;
            if (i == count - 1) {
                startAngel = M_PI_2 + perAngle * i - (_scaleWidth / 2) / radius;
            }
        }else{
            startAngel = M_PI_2 - perAngle * i;
            if (i == count - 1) {
                startAngel = M_PI_2 - perAngle * i + (_scaleWidth / 2) / radius;
            }
        }
        CGFloat endAngel = 0;
        if (isLeft) {
            endAngel = startAngel + _scaleWidth / radius;
            if (i == 0 || i == count - 1) {
                endAngel = startAngel + (_scaleWidth / 2) / radius;
            }
        }else{
            endAngel = startAngel - _scaleWidth / radius;
            if (i == 0 || i == count - 1) {
                endAngel = startAngel - (_scaleWidth / 2) / radius;
            }
        }
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:startAngel endAngle:endAngel clockwise:isLeft?YES:NO];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.strokeColor = scaleColor.CGColor;
        perLayer.lineWidth = _scaleLength;
        if (_scaleStyle == YJWaveScaleStyle_Clock) {
            if (i % 5 == 0) {
                perLayer.lineWidth = _scaleLength;
            }else{
                perLayer.lineWidth = _scaleLength / 2;
            }
        }
        perLayer.path = tickPath.CGPath;
        [scaleArr addObject:perLayer];
    }
    return scaleArr;
}

/**
 *  画刻度背景
 *
 */
- (void)drawScaleBackground{
    [self.scaleBackLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    CALayer *leftLayer = [CALayer layer];
    leftLayer.frame = CGRectMake(0, 0, scaleRect.size.width / 2, scaleRect.size.height);
    [self.scaleBackLayer addSublayer:leftLayer];
    CALayer *rightLayer = [CALayer layer];
    rightLayer.frame = CGRectMake(scaleRect.size.width / 2, 0, scaleRect.size.width / 2, scaleRect.size.height);
    [self.scaleBackLayer addSublayer:rightLayer];
    // 画左边的刻度盘
    leftLayer.sublayers = [self drawScaleWithColor:_scaleBgColor isLeft:YES];
    
    // 画右边的刻度盘
    rightLayer.sublayers = [self drawScaleWithColor:_scaleBgColor isLeft:NO];
}

/**
 *  画刻度
 *
 */
- (void)drawScale{
    [self.scaleLeftLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.scaleRightLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // 画左边的刻度盘
    self.scaleLeftLayer.sublayers = [self drawScaleWithColor:_scaleColor isLeft:YES];
    
    // 画右边的刻度盘
    self.scaleRightLayer.sublayers = [self drawScaleWithColor:_scaleColor isLeft:NO];
    
    //左边的圆心坐标
    CGPoint leftCenterPoint = CGPointMake(scaleRect.size.width / 2, scaleRect.size.height / 2);
    //右边的圆心坐标
    CGPoint rightCenterPoint = CGPointMake(0, scaleRect.size.height / 2);
    CGFloat radius = (scaleRect.size.width - _scaleLength) / 2;
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithArcCenter:leftCenterPoint radius:radius startAngle:M_PI_2 endAngle:-M_PI_2 clockwise:YES];
    self.scaleLeftMaskLayer.path = leftPath.CGPath;
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithArcCenter:rightCenterPoint radius:radius startAngle:M_PI_2 endAngle:-M_PI_2 clockwise:NO];
    self.scaleRightMaskLayer.path = rightPath.CGPath;
}

/**
 *  画水波背景
 *
 */
- (void)drawWaveBackground {
    //画背景圆
    CGPoint centerPoint = CGPointMake(waveRect.size.width / 2, waveRect.size.height / 2);
    CGFloat radius = waveRect.size.width / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    self.waveBackLayer.path = path.CGPath;
}

/**
 *  画波浪
 *
 */
- (void)drawWave {
    
    CGFloat amplitude = self.amplitude;
    if (currentWavePointY <= 0.0 || currentWavePointY == waveRect.size.height) {
        amplitude = 0.f;
    }
    
    //画圆形mask
    CGPoint centerPoint = CGPointMake(waveRect.size.width / 2, waveRect.size.height / 2);
    CGFloat radius = waveRect.size.width / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.waveLayer.mask = mask;
    
    CGFloat waveLength = _waveLength;
    if (waveLength==0) {
        CGFloat radius = waveRect.size.width/2;
        CGFloat distanceToOrigin = fabs((currentWavePointY-radius));
        CGFloat mindistanceToOrigin = fabs((waveRect.size.height*0.2-radius));
        CGFloat minWaveLength = 2 * 2 * sqrtf(powf(radius, 2) - powf(mindistanceToOrigin, 2));
        waveLength = 2 * 2 * sqrtf(powf(radius, 2) - powf(distanceToOrigin, 2));
        waveLength = MAX(minWaveLength, waveLength);
    }
    CGMutablePathRef wavePath = CGPathCreateMutable();
    
    //画水
    CGFloat waterWaveWidth = waveRect.size.width;
    CGPathMoveToPoint(wavePath, nil, 0, currentWavePointY);
    CGFloat y = 0.0f;
    
    waterWaveWidth = waveRect.size.width;
    for(float x = 0; x <= waterWaveWidth; x++){
        y =  variable * amplitude* sinf((2*M_PI/waveLength) * x - offsetX * M_PI / 180) + currentWavePointY;
        CGPathAddLineToPoint(wavePath, nil, x, y);
    }
    
    CGPathAddLineToPoint(wavePath, nil, waterWaveWidth, waveRect.size.height);
    CGPathAddLineToPoint(wavePath, nil, 0, waveRect.size.height);
    CGPathCloseSubpath(wavePath);
    
    self.waveLayer.path = wavePath;
    
    CGPathRelease(wavePath);
}

/**
 *  绘制文本
 *
 */
- (void)drawText {
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    if (_percentageAttributedText.length) {
        [attributedText appendAttributedString:_percentageAttributedText];
    }else{
        attributedText = [self formatPercentage:_progress * 100];
    }
    
    NSMutableAttributedString *descriptionAttributedText = [[NSMutableAttributedString alloc] init];
    if (_descriptionAttributedText.length) {
        [descriptionAttributedText appendAttributedString:_descriptionAttributedText];
    }else{
        if (_descriptionText.length) {
            descriptionAttributedText = [self formatDescription:[NSString stringWithFormat:@"\n%@",_descriptionText]];
        }
    }
    
    if (descriptionAttributedText.length) {
        [attributedText appendAttributedString:descriptionAttributedText];
    }
    
    self.textLb.attributedText = attributedText;
}

#pragma mark - setter
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    // 开始抖波
    [self startWave];
    // 重绘文本
    [self drawText];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刻度动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.fromValue = @(self->currentPercent);
        animation.toValue = @(self.progress);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        self->currentPercent = self.progress;
        [self.scaleLeftMaskLayer addAnimation:animation forKey:@"strokeEndAnimation"];
        [self.scaleRightMaskLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    });
    
   
}

- (void)setWaterBgColor:(UIColor *)waterBgColor {
    _waterBgColor = waterBgColor;
    self.waveBackLayer.fillColor = waterBgColor.CGColor;
}

- (void)setWaterColor:(UIColor *)waterColor {
    _waterColor = waterColor;
    self.waveLayer.fillColor = waterColor.CGColor;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    [self drawText];
}

- (void)setDescriptionText:(NSString *)descriptionText{
    _descriptionText = [descriptionText copy];
    [self drawText];
}

- (void)setDescriptionFont:(UIFont *)descriptionFont{
    _descriptionFont = descriptionFont;
    [self drawText];
}

- (void)setNumberFont:(UIFont *)numberFont{
    _numberFont = numberFont;
    [self drawText];
}

- (void)setPercentFont:(UIFont *)percentFont{
    _percentFont = percentFont;
    [self drawText];
}

- (void)setDescriptionAttributedText:(NSAttributedString *)descriptionAttributedText{
    _descriptionAttributedText = [descriptionAttributedText copy];
    [self drawText];
}

- (void)setPercentageAttributedText:(NSAttributedString *)percentageAttributedText{
    _percentageAttributedText = [percentageAttributedText copy];
    [self drawText];
}

- (void)setScaleLength:(CGFloat)scaleLength{
    _scaleLength = scaleLength;
    self.scaleLeftMaskLayer.lineWidth = scaleLength;
    self.scaleRightMaskLayer.lineWidth = scaleLength;
}

- (void)setAllowCoreMotion:(BOOL)allowCoreMotion{
    _allowCoreMotion = allowCoreMotion;
    [self startGravity];
}

#pragma mark - getter
- (CAShapeLayer *)waveLayer{
    if (!_waveLayer) {
        _waveLayer = [CAShapeLayer layer];
        _waveLayer.fillColor = _waterColor.CGColor;
    }
    return _waveLayer;
}
- (CAShapeLayer *)waveBackLayer{
    if (!_waveBackLayer) {
        _waveBackLayer = [CAShapeLayer layer];
        _waveBackLayer.fillColor = _waterBgColor.CGColor;
    }
    return _waveBackLayer;
}
- (CAShapeLayer *)scaleBackLayer{
    if (!_scaleBackLayer) {
        _scaleBackLayer = [CAShapeLayer layer];
    }
    return _scaleBackLayer;
}
- (CAShapeLayer *)scaleLayer{
    if (!_scaleLayer) {
        _scaleLayer = [CAShapeLayer layer];
    }
    return _scaleLayer;
}
- (CAShapeLayer *)scaleLeftLayer{
    if (!_scaleLeftLayer) {
        _scaleLeftLayer = [CAShapeLayer layer];
        _scaleLeftLayer.mask = self.scaleLeftMaskLayer;
    }
    return _scaleLeftLayer;
}
- (CAShapeLayer *)scaleRightLayer{
    if (!_scaleRightLayer) {
        _scaleRightLayer = [CAShapeLayer layer];
        _scaleRightLayer.mask = self.scaleRightMaskLayer;
    }
    return _scaleRightLayer;
}
- (CAShapeLayer *)scaleLeftMaskLayer{
    if (!_scaleLeftMaskLayer) {
        _scaleLeftMaskLayer = [CAShapeLayer layer];
        _scaleLeftMaskLayer.lineWidth = _scaleLength;
        _scaleLeftMaskLayer.strokeColor = [UIColor redColor].CGColor;
        _scaleLeftMaskLayer.fillColor = [UIColor clearColor].CGColor;
        _scaleLeftMaskLayer.strokeStart = 0;
        _scaleLeftMaskLayer.strokeEnd = 0;
    }
    return _scaleLeftMaskLayer;
}
- (CAShapeLayer *)scaleRightMaskLayer{
    if (!_scaleRightMaskLayer) {
        _scaleRightMaskLayer = [CAShapeLayer layer];
        _scaleRightMaskLayer.lineWidth = _scaleLength;
        _scaleRightMaskLayer.strokeColor = [UIColor redColor].CGColor;
        _scaleRightMaskLayer.fillColor = [UIColor clearColor].CGColor;
        _scaleRightMaskLayer.strokeStart = 0;
        _scaleRightMaskLayer.strokeEnd = 0;
    }
    return _scaleRightMaskLayer;
}
- (UILabel *)textLb{
    if (!_textLb) {
        _textLb = [UILabel new];
        _textLb.textAlignment = NSTextAlignmentCenter;
        _textLb.textColor = [UIColor whiteColor];
        _textLb.numberOfLines = 0;
    }
    return _textLb;
}
- (CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 0.02;// 0.02; // 50 Hz
    }
    return _motionManager;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self configureDrawingRects];
    currentWavePointY = waveRect.size.height;
 
    // 水波
    self.waveBackLayer.frame = waveRect;
    self.waveLayer.frame = self.waveBackLayer.bounds;
    currentTransform = self.waveLayer.affineTransform;
    // 文本
    self.textLb.frame = waveRect;
    // 刻度
    self.scaleBackLayer.frame = scaleRect;
    self.scaleLayer.frame = scaleRect;
    self.scaleLeftLayer.frame = CGRectMake(0, 0, scaleRect.size.width/2, scaleRect.size.height);
    self.scaleRightLayer.frame = CGRectMake(scaleRect.size.width/2, 0, scaleRect.size.width/2, scaleRect.size.height);
    
}

@end

@implementation YJWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[YJWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end
