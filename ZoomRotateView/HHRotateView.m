//
//  HHRotateView.m
//  缩放轮播图
//
//  Created by hxw on 16/7/16.
//  Copyright © 2016年 HXW. All rights reserved.
//

#import "HHRotateView.h"

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) CGFloat maxX;
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;


@end

typedef NS_ENUM(NSUInteger, Direction)
{
    DirectionNone,
    DirectionLeft,
    DirectionRight,
};

#define DEFAULTTIME 3
#define DEFAULTBGWIDTH 50
#define DEFAULTPAGEBOTTOM 10
#define DEFAULTLABELMARGIN 10

#define SCROLLVIEWTAG 123320
#define DEFAULTDISTANCE -64

#define DEFAULTWAVESPEED 0.03f
#define DEFAULTWAVEHEIGHT 6.0f
#define DEFAULTLINEHEIGHT 4.0f

@interface HHRotateView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *currImageView;
@property (nonatomic, strong) UIImageView *otherImageView;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *describeArray;
@property (nonatomic, strong) NSMutableArray *tempImageArray;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) CGSize pageImageSize;
@property (nonatomic, assign) NSInteger currIndex;
@property (nonatomic, assign) NSInteger nextIndex;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) BOOL showScale;
@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, assign) CGFloat offsetY;

@property (nonatomic, strong) CADisplayLink *waveDisplayLink;
@property (nonatomic, strong) CAShapeLayer *waveShapeLayer;
@property (nonatomic, assign) CGFloat waveOffsetX;
@property (nonatomic, strong) CALayer *indicatorLayer;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, strong) NSArray *animationArray;

@end

@implementation HHRotateView


#pragma mark 懒加载
- (CADisplayLink *)waveDisplayLink
{
    if (!_waveDisplayLink) {
        _waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(configWavePath)];
        [_waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _waveDisplayLink.paused = YES;
    }
    return _waveDisplayLink;
}

- (CAShapeLayer *)waveShapeLayer
{
    if (!_waveShapeLayer) {
        _waveShapeLayer = [CAShapeLayer layer];
        _waveShapeLayer.frame = CGRectMake(0, self.height-DEFAULTWAVEHEIGHT, self.width, DEFAULTWAVEHEIGHT);
        [self.layer addSublayer:self.waveShapeLayer];
        _waveShapeLayer.fillColor = [UIColor whiteColor].CGColor;
        _waveShapeLayer.zPosition = 2.0f;
    }
    return _waveShapeLayer;
}

- (UIImageView *)currImageView
{
    if (!_currImageView) {
        _currImageView = [[UIImageView alloc]init];
        _currImageView.layer.masksToBounds = YES;
        _currImageView.clipsToBounds = YES;
        _currImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        _currImageView.bounds = self.bounds;
    }
    return _currImageView;
}
- (UIImageView *)otherImageView
{
    if (!_otherImageView) {
        _otherImageView = [[UIImageView alloc]init];
        _otherImageView.layer.masksToBounds = YES;
        _otherImageView.clipsToBounds = YES;
        _otherImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
        _otherImageView.bounds = self.bounds;
    }
    return _otherImageView;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [[NSTimer alloc]init];
    }
    return _timer;
}

- (NSMutableArray *)tempImageArray
{
    if (!_tempImageArray) {
        _tempImageArray = [NSMutableArray array];
    }
    return _tempImageArray;
}
- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (UIView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _shadowView.hidden = YES;
        [self addSubview:_shadowView];
    }
    return _shadowView;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.textColor = [UIColor whiteColor];
        _describeLabel.backgroundColor = [UIColor clearColor];
        _describeLabel.textAlignment = NSTextAlignmentLeft;
        _describeLabel.font = [UIFont systemFontOfSize:18];
        [self.shadowView addSubview:_describeLabel];
    }
    return _describeLabel;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.tag = SCROLLVIEWTAG;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.frame = self.bounds;
        _scrollView.layer.masksToBounds = NO;
        self.currImageView.userInteractionEnabled = YES;
        [_currImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClick)]];
        [_scrollView addSubview:_currImageView];
        [_scrollView addSubview:self.otherImageView];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIViewController *)viewController
{
    if (![self superview]) return nil;
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]] && [nextResponder conformsToProtocol:@protocol(HHRotateViewDelegate)])
        {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (UITableView *)tableView
{
    if (_tableView) return _tableView;
    if(![self superview]) return nil;
    for (UIView *next = [self superview]; next; next = next.superview) {
        if ([next isKindOfClass:[UITableView class]])
        {
            self.tableView = (UITableView *)next;
            return (UITableView *)next;
        }
    }
    return nil;
}


#pragma mark 赋值方法

- (void)setWaveFrequency:(CGFloat)waveFrequency
{
    _waveFrequency = waveFrequency / 100;
}

- (void)setWaveColor:(UIColor *)waveColor
{
    _waveColor = waveColor;
    self.waveShapeLayer.fillColor = _waveColor.CGColor;
}

- (void)setShowScale:(BOOL)showScale
{
    _showScale = showScale;
}

- (void)setDelegate:(id<HHRotateViewDelegate>)delegate
{
    _delegate = delegate;
}
- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    self.shadowView.backgroundColor = shadowColor;
}
- (void)setLabelOrigin:(CGPoint)labelOrigin
{
    _labelOrigin = labelOrigin;
    self.describeLabel.origin = labelOrigin;
}

- (void)setTimeInterVal:(NSTimeInterval)timeInterVal {
    _timeInterVal = timeInterVal;
    [self startTimer];
}
- (void)setShadowHeight:(CGFloat)shadowHeight
{
    _shadowHeight = shadowHeight;
}

- (void)setPageControlBottomMargin:(CGFloat)pageControlBottomMargin
{
    _pageControlBottomMargin = pageControlBottomMargin;
}

- (void)setScrollViewBottomMargin:(CGFloat)scrollViewBottomMargin
{
    _scrollViewBottomMargin = scrollViewBottomMargin;
    self.scrollView.height = self.height - scrollViewBottomMargin;
}

-(void)setLabelAttribute:(LabelAttribute)labelAttribute
{
    _labelAttribute = labelAttribute;
    self.describeLabel.textColor = labelAttribute.textColor;
    self.describeLabel.font = [UIFont systemFontOfSize:labelAttribute.fontSize];
}

- (void)setPageImage:(PageControlImage)pageImage
{
    _pageImage = pageImage;
    UIImage *commonImage = [UIImage imageNamed:pageImage.commonImageString];
    UIImage *currentImage = [UIImage imageNamed:pageImage.currentImageString];
    if (!commonImage || !currentImage) return;
    self.pageImageSize = commonImage.size;
    [self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
    [self.pageControl setValue:commonImage forKey:@"_pageImage"];
}
- (void)setPageColor:(PageControlColor)pageColor
{
    _pageColor = pageColor;
    UIColor *commonColor = pageColor.commonColor;
    UIColor *currentColor = pageColor.currentColor;
    if (!commonColor || !currentColor) return;
    self.pageControl.pageIndicatorTintColor = commonColor;
    self.pageControl.currentPageIndicatorTintColor = currentColor;
}

- (void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    if (!imageArray.count) return;
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            [self.tempImageArray addObject:imageArray[i]];
        } else if ([imageArray[i] isKindOfClass:[NSString class]]){
            [self.tempImageArray addObject:[self placeholdImage]];
            [self downloadImages:i];
        }
    }
    self.currImageView.image = self.tempImageArray.firstObject;
    self.pageControl.numberOfPages = self.tempImageArray.count;
}

- (UIImage *)placeholdImage
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"placeholdResource.bundle" ofType:nil];
    NSString *placeholdPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"placehold.png" ofType:nil];
    return [UIImage imageWithContentsOfFile:placeholdPath];
}

- (void)setDescribeArray:(NSArray *)describeArray
{
    _describeArray = describeArray;
    if (describeArray && describeArray.count > 0) {
        if (describeArray.count < self.tempImageArray.count) {
            NSMutableArray *describes = [NSMutableArray arrayWithArray:describeArray];
            for (NSInteger i = describeArray.count; i < self.tempImageArray.count; i++) {
                [describes addObject:@""];
            }
            _describeArray = describes;
        }
        self.shadowView.hidden = NO;
        self.describeLabel.text = _describeArray.firstObject;
    }
}

#pragma mark 初始化设置
+ (void)initialize
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HHRotate"];
    BOOL hasDoc = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&hasDoc];
    if (!isExists || !hasDoc)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (instancetype)rotateViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray showScale:(BOOL)showScale
{
    return [[self alloc] initWithFrame:frame imageArray:imageArray showScale:showScale];
}
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray showScale:(BOOL)showScale
{
    if (self = [super initWithFrame:frame]) {
        self.imageArray = imageArray;
        self.frame = frame;
        self.showScale = showScale;
    }
    return self;
}

+ (instancetype)rotateViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray describeArray:(NSArray *)describeArray showScale:(BOOL)showScale
{
    return [[self alloc] initWithFrame:frame imageArray:imageArray describeArray:describeArray showScale:showScale];
}

- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray describeArray:(NSArray *)describeArray showScale:(BOOL)showScale
{
    if (self = [self initWithFrame:frame imageArray:imageArray showScale:showScale]) {
        self.describeArray = describeArray;
    }
    return self;
}

#pragma mark 下载网络图片
- (void)downloadImages:(int)index
{
    NSString *key = _imageArray[index];
    NSString *path = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HHRotate"] stringByAppendingPathComponent:[key lastPathComponent]];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        self.tempImageArray[index] = [UIImage imageWithData:data];
        return;
    }
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:key]];
        if (!data) return;
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.tempImageArray[index] = image;
            if (_currIndex == index) [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            [data writeToFile:path atomically:YES];
        }
    }];
    [self.queue addOperation:download];
}

#pragma mark 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
    CGFloat shadowH = _shadowHeight ? _shadowHeight : DEFAULTBGWIDTH;
    self.shadowView.frame = CGRectMake(0, self.height - shadowH, self.width,shadowH);
    self.describeLabel.frame = CGRectMake(DEFAULTLABELMARGIN, DEFAULTLABELMARGIN / 2, self.width - 2 * DEFAULTLABELMARGIN, 20);
    if (self.labelOrigin.x)
        self.describeLabel.frame = CGRectMake(self.labelOrigin.x, self.labelOrigin.y, self.width - 2 * self.labelOrigin.x, 20);
    self.scrollView.frame = self.bounds;
    if([self tableView])
    [[self tableView] setContentOffset:CGPointZero];
    [self bringSubviewToFront:_pageControl];
    [self insertSubview:_shadowView aboveSubview:self.scrollView];
    [self setPageControlPosition];
    [self setScrollViewContentSize];
    [self setDelegate];
    [self scaleImageView];
}

- (void)scaleImageView
{
    if(!_showScale || ![self tableView])return;
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat offsetY = self.tableView.contentOffset.y;
    
    self.offsetY = offsetY;
    self.currImageView.layer.frame = CGRectMake(self.width, offsetY, self.width, self.height-offsetY);
    self.otherImageView.layer.frame = self.direction == DirectionLeft ? CGRectMake(2*self.width, offsetY, self.width, self.height-offsetY):CGRectMake(0, offsetY, self.width, self.height-offsetY);
    if (offsetY <= DEFAULTDISTANCE-1) {
        
        if(self.offsetY <= DEFAULTDISTANCE && !self.tableView.isDragging && !self.isRefreshing && _showScale)
        {
            self.isRefreshing = YES;
            [self.tableView setContentInset:UIEdgeInsetsMake(-DEFAULTDISTANCE, 0, 0, 0)];
            
            [self startWave];
            
            if ([_delegate respondsToSelector:@selector(pullToSendNetworkRequest:)])
            {
                [_delegate pullToSendNetworkRequest:self];
            }
        }
    }else if(offsetY + self.tableView.height > (self.tableView.contentSize.height < self.tableView.height ? self.tableView.height : self.tableView.contentSize.height) - DEFAULTDISTANCE && !self.isRefreshing)
    {
        self.isRefreshing = YES;
        if ([_delegate respondsToSelector:@selector(pushToSendNetworkRequest:)])
        {
            [_delegate pushToSendNetworkRequest:self];
        }
    }
    self.tableView.isDragging ? [self stopTimer] : [self startTimer];
}

- (void)stopPushRefresh
{
    self.isRefreshing = NO;
}

- (void)setDelegate
{
    if (self.delegate == nil && [self viewController])
    {
        self.delegate = (UIViewController<HHRotateViewDelegate>*)[self viewController];
    }
}

- (void)setPageControlPosition
{
    CGSize size;
    if (_pageImageSize.width == 0) {
        size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
        size.height = 20;
    } else {
        size = CGSizeMake(_pageImageSize.width * (_pageControl.numberOfPages * 2 - 1), _pageImageSize.height);
    }
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);
    _pageControl.center = CGPointMake(self.width * 0.5, _pageControlBottomMargin ? self.height - _pageControlBottomMargin : self.height - DEFAULTPAGEBOTTOM);
}

#pragma mark 设置scrollView的contentSize
- (void)setScrollViewContentSize
{
    if (self.tempImageArray.count > 1) {
        self.scrollView.contentSize = CGSizeMake(self.width * 3, 0);
        self.scrollView.contentOffset = CGPointMake(self.width, 0);
        self.currImageView.frame = CGRectMake(self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
        [self startTimer];
    } else {
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.height);
    }
}

- (void)startTimer
{
    if (self.tempImageArray.count <= 1) return;
    if (self.timer) [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:_timeInterVal < 1 ? DEFAULTTIME : _timeInterVal target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)stopTimer
{
    if (!self.timer)return;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage
{
    [self.scrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
}

#pragma mark 当图片滚动过半时就修改当前页码、标签
- (void)changeCurrentPageWithOffset:(CGFloat)offsetX
{
    if (offsetX < self.width * 0.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.tempImageArray.count - 1;
        _pageControl.currentPage = index;
        self.describeLabel.text = self.describeArray[index];
    } else if (offsetX > self.width * 1.5){
        _pageControl.currentPage = (self.currIndex + 1) % self.tempImageArray.count;
        self.describeLabel.text = self.describeArray[(self.currIndex + 1) % self.tempImageArray.count];
    } else {
        _pageControl.currentPage = self.currIndex;
        self.describeLabel.text = self.describeArray[self.currIndex];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    self.otherImageView.hidden = NO;
    [self changeCurrentPageWithOffset:offsetX];
    
    self.direction = offsetX > self.width ? DirectionLeft : offsetX < self.width ? DirectionRight : DirectionNone;
    
    if (self.direction == DirectionRight) {
        
        self.otherImageView.center = CGPointMake(self.currImageView.centerX - self.width, self.currImageView.centerY);
        
        if (self.rotateMode == RotateMode3D) {
            
            self.otherImageView.layer.anchorPoint = CGPointMake(1, 0.5);
            self.rate = 1 - offsetX / self.width;
            self.otherImageView.layer.transform = [self transformRate:self.rate direction: DirectionRight];
        }
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) self.nextIndex = self.tempImageArray.count - 1;
        if (self.scrollView.contentOffset.x <= 0) {
            [self changeImageView];
        }
    } else if (self.direction == DirectionLeft){
        
        if (self.rotateMode == RotateMode3D) {
            
            self.otherImageView.center = self.currImageView.center;
            
            self.otherImageView.layer.anchorPoint = CGPointMake(0, 0.5);
            self.rate = 1 - (2 * self.width - offsetX) / self.width;
            
            self.otherImageView.layer.transform = [self transformRate:self.rate direction: DirectionLeft];
        }else
        {
            self.otherImageView.center = CGPointMake(CGRectGetMidX(self.currImageView.frame) + self.width, self.center.y + self.offsetY/2);
        }
        
        self.nextIndex = (self.currIndex + 1) % self.tempImageArray.count;
        if (self.scrollView.contentOffset.x >= self.width * 2) {
            [self changeImageView];
        }
    }
    self.otherImageView.image = self.tempImageArray[self.nextIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.otherImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.otherImageView.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.otherImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.otherImageView.hidden = YES;
}

- (CATransform3D)transformRate:(CGFloat)rate direction:(Direction)direction
{
    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = -1.0 / 1000.0;
    CGFloat angle = direction == DirectionLeft ? (1.0 - rate) * M_PI_2 : (1.0 - rate) * -M_PI_2;
    NSLog(@"%lf",angle);
    CATransform3D rotateTransform = CATransform3DRotate(identity, angle, 0, 1, 0);
    CATransform3D translateTransform = CATransform3DMakeTranslation(self.width/2, 0.0, 0.0);
    return CATransform3DConcat(rotateTransform, translateTransform);
}

- (void)changeImageView
{
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(self.width, 0);
    self.currIndex = self.nextIndex;
    self.pageControl.currentPage = self.currIndex;
    self.describeLabel.text = self.describeArray[self.currIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];    
}

- (void)imageViewClick
{
    if ([_delegate respondsToSelector:@selector(rotateView:didClickImage:)]){
        [_delegate rotateView:self didClickImage:self.currIndex];
    }
}
- (void)dealloc
{
    if(!_showScale || ![self tableView])return;
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)startWave
{
    if (self.waveShapeLayer.path) {
        return;
    }
    self.waveDisplayLink.paused = NO;
}

- (void)stopWave
{
    [self.tableView setContentInset:UIEdgeInsetsZero];
    self.isRefreshing = NO;
    self.waveOffsetX = 0;
    [self.waveDisplayLink invalidate];
    self.waveDisplayLink = nil;
    self.waveShapeLayer.path = nil;
}

- (void)configWavePath
{
    self.waveOffsetX -= 0.1;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    
    CGFloat y = 0.f;
    for (CGFloat x = 0.f; x <= self.width ; x++)
    {
        y = DEFAULTWAVEHEIGHT * sin(_waveFrequency ? _waveFrequency * x + self.waveOffsetX : DEFAULTWAVESPEED * x + self.waveOffsetX);
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGPathAddLineToPoint(path, NULL, self.width, DEFAULTWAVEHEIGHT);
    CGPathAddLineToPoint(path, NULL, 0, DEFAULTWAVEHEIGHT);
    CGPathCloseSubpath(path);
    self.waveShapeLayer.path = path;
    CGPathRelease(path);
}

@end

@implementation UIView (Frame)

@dynamic maxX;
@dynamic maxY;

/********-----------------------------------------***********/
#pragma mark -坐标层
/********-----------------------------------------***********/

- (void)setX:(CGFloat)x
{
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = x;
    self.frame = tempFrame;
}
- (CGFloat)x
{
    return self.frame.origin.x;
}
- (void)setY:(CGFloat)y
{
    CGRect tempFrame = self.frame;
    tempFrame.origin.y = y;
    self.frame = tempFrame;
}
- (CGFloat)y
{
    return self.frame.origin.y;
}
- (void)setWidth:(CGFloat)width
{
    CGRect tempFrame = self.frame;
    tempFrame.size.width = width;
    self.frame = tempFrame;
}
- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect tempFrame = self.frame;
    tempFrame.size.height = height;
    self.frame = tempFrame;
}
- (CGFloat)height
{
    return self.frame.size.height;
}
- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
- (CGSize)size
{
    return self.frame.size;
}
- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}
- (CGPoint)origin
{
    return self.frame.origin;
}
- (CGFloat)maxX
{
    return self.x+self.width;
}
- (CGFloat)maxY
{
    return self.y+self.height;
}
- (CGFloat)centerX
{
    return self.center.x;
}
- (void)setCenterX:(CGFloat)centerX
{
    CGPoint centerPoint = self.center;
    centerPoint.x = centerX;
    self.center = centerPoint;
}
-(CGFloat)centerY
{
    return self.center.y;
}
- (void)setCenterY:(CGFloat)centerY
{
    CGPoint centerPoint = self.center;
    centerPoint.y = centerY;
    self.center = centerPoint;
}

@end





