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

@interface YJWaveProgressView()
{
    CGRect fullRect;            // 视图frame
    CGRect waveRect;            // 水波frame
    
    CGFloat currentWavePointY;  // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    CGFloat offsetX;            // 波浪x位移
    
    float variable;             // 可变参数 更加真实 模拟波纹
    BOOL increase;              // 增减变化
    
}

/// 刷新定时器
@property (nonatomic, strong) CADisplayLink *displayLink;

/// 水波背景层
@property (nonatomic, strong) CAShapeLayer *waveBackLayer;
/// 水波层
@property (nonatomic, strong) CAShapeLayer *waveLayer;
/// 圆形遮罩
@property (nonatomic, strong) CAShapeLayer *maskLayer;
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
    
    // 水波颜色
    _waterColor = [UIColor colorWithRed:0.325 green:0.392 blue:0.729 alpha:1.00];
    // 波浪背景填充色
    _waterBgColor = [UIColor colorWithRed:0.259 green:0.329 blue:0.506 alpha:1.00];
    
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
}

- (void)setupLayer{
    // 添加背景层
    [self.layer addSublayer:self.waveBackLayer];
    
    // 添加水波层
    [self.layer addSublayer:self.waveLayer];
    
    // 添加文本
    [self addSubview:self.textLb];
}

- (void)configureDrawingRects
{
    fullRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    CGFloat offset = 0;
    waveRect = CGRectMake(offset,
                          offset,
                          fullRect.size.width - 2 * offset,
                          fullRect.size.height - 2 * offset);
}


#pragma mark - wave
// 动态更新水波
- (void)updateWave:(CADisplayLink *)displayLink {
    [self animateWave];
    [self updateWaveY];
    [self setNeedsDisplay];
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
    _displayLink = [CADisplayLink displayLinkWithTarget:[YJWeakProxy proxyWithTarget:self] selector:@selector(updateWave:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// 停止波动
- (void)stopWave {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
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

/**
 *  根据圆心点和圆上一个点计算角度
 *
 *  @param centerPoint 圆心点
 *  @param point       圆上的一个点
 *
 *  @return 角度
 */
- (CGFloat)calculateRotateDegree:(CGPoint)centerPoint point:(CGPoint)point {
    
    CGFloat rotateDegree = asin(fabs(point.y - centerPoint.y) / (sqrt(pow(point.x - centerPoint.x, 2) + pow(point.y - centerPoint.y, 2))));
    
    //如果point纵坐标大于原点centerPoint纵坐标(在第一和第二象限)
    if (point.y > centerPoint.y) {
        //第一象限
        if (point.x >= centerPoint.x) {
            rotateDegree = rotateDegree;
        }
        //第二象限
        else {
            rotateDegree = M_PI - rotateDegree;
        }
    } else //第三和第四象限
    {
        if (point.x <= centerPoint.x) //第三象限，不做任何处理
        {
            rotateDegree = M_PI + rotateDegree;
        }
        else //第四象限
        {
            rotateDegree = 2 * M_PI - rotateDegree;
        }
    }
    return rotateDegree;
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawWaveBackground];
    [self drawWave];
    [self drawLabel];

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
    self.maskLayer.path = path.CGPath;
    
    CGMutablePathRef wavePath = CGPathCreateMutable();
    
    //画水
    CGFloat waterWaveHeight = waveRect.size.height * _progress;
    CGFloat waterWaveWidth = waveRect.size.width;
    CGPathMoveToPoint(wavePath, nil, 0, waterWaveHeight);
    CGFloat y = 0.0f;
    
    waterWaveWidth = waveRect.size.width;
    for(float x = 0; x <= waterWaveWidth; x++){
        y =  variable * amplitude* sinf((2*M_PI/_waveLength) * x - offsetX * M_PI / 180) + currentWavePointY;
        CGPathAddLineToPoint(wavePath, nil, x, y);
    }
    
    CGPathAddLineToPoint(wavePath, nil, waterWaveWidth, waveRect.size.height);
    CGPathAddLineToPoint(wavePath, nil, 0, waveRect.size.height);
    CGPathCloseSubpath(wavePath);
    
    self.waveLayer.path = wavePath;
    
    CGPathRelease(wavePath);
}

/**
 *  文本
 *
 */
- (void)drawLabel {
    
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
    [self startWave];
}

- (void)setWaterBgColor:(UIColor *)waterBgColor {
    _waterBgColor = waterBgColor;
    self.waveBackLayer.fillColor = waterBgColor.CGColor;
}

- (void)setWaterColor:(UIColor *)waterColor {
    _waterColor = waterColor;
    self.waveLayer.fillColor = waterColor.CGColor;
}

- (void)setAmplitude:(CGFloat)amplitude {
    _amplitude = amplitude;
    [self setNeedsDisplay];
}

- (void)setWaveLength:(CGFloat)waveLength {
    _waveLength = waveLength;
    [self setNeedsDisplay];
}

#pragma mark - getter
- (CAShapeLayer *)waveLayer{
    if (!_waveLayer) {
        _waveLayer = [CAShapeLayer layer];
        _waveLayer.fillColor = _waterColor.CGColor;
        _waveLayer.mask = self.maskLayer;
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
- (CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
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

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    [self configureDrawingRects];
    currentWavePointY = waveRect.size.height;
    if (_waveLength==0) {
        _waveLength = waveRect.size.width*2;
    }
    self.waveBackLayer.frame = waveRect;
    self.waveLayer.frame = waveRect;
    self.textLb.frame = waveRect;
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
