//
//  HHRotateView.h
//  缩放轮播图
//
//  Created by hxw on 16/7/16.
//  Copyright © 2016年 HXW. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef struct LabelAttributes {
    __unsafe_unretained  UIColor *textColor;
    CGFloat fontSize;
} LabelAttribute;

UIKIT_STATIC_INLINE LabelAttribute labelAttributeMake(UIColor *textColor, CGFloat fontSize)
{
    LabelAttribute labelAtt = {textColor, fontSize};
    return labelAtt;
}

typedef struct PageControlImages {
    __unsafe_unretained  NSString *commonImageString;
    __unsafe_unretained  NSString *currentImageString;
} PageControlImage;


UIKIT_STATIC_INLINE PageControlImage pageImageMake(NSString *commonImageString, NSString *currentImageString)
{
    PageControlImage pageImage = {commonImageString, currentImageString};
    return pageImage;
}

typedef struct PageControlColors {
    __unsafe_unretained  UIColor *commonColor;
    __unsafe_unretained  UIColor *currentColor;
} PageControlColor;


UIKIT_STATIC_INLINE PageControlColor pageColorMake(UIColor *commonColor, UIColor *currentColor)
{
    PageControlColor pageColor = {commonColor, currentColor};
    return pageColor;
}


typedef NS_ENUM(NSUInteger, DescribeLabelPosition)
{
    DescribeLabelPositionNone,
    DescribeLabelPositionCenter,
    DescribeLabelPositionLeft,
};

typedef NS_ENUM(NSUInteger, RotateMode)
{
    RotateModeNormal,
    RotateMode3D,
};

/*
 pageImageMake(@"", @"");
 pageColorMake([UIColor whiteColor], [UIColor whiteColor]);
 labelAttributeMake([UIColor whiteColor], 20);
 */

@class HHRotateView;
@protocol HHRotateViewDelegate <NSObject>

@optional
- (void)rotateView:(HHRotateView *)rotateView didClickImage:(NSInteger)index;
- (void)pullToSendNetworkRequest:(HHRotateView *)rotateView;
- (void)pushToSendNetworkRequest:(HHRotateView *)rotateView;

@end

@interface HHRotateView : UIView

@property (nonatomic, weak) id<HHRotateViewDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval timeInterVal;
@property (nonatomic, assign) CGFloat shadowHeight;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGPoint labelOrigin;
@property (nonatomic, assign) CGFloat pageControlBottomMargin;
@property (nonatomic, assign) CGFloat scrollViewBottomMargin;

@property (nonatomic, assign) LabelAttribute labelAttribute;
@property (nonatomic, assign) PageControlImage pageImage;
@property (nonatomic, assign) PageControlColor pageColor;

@property (nonatomic, assign) CGFloat waveFrequency;
@property (nonatomic, strong) UIColor *waveColor;
@property (nonatomic, assign) RotateMode rotateMode;


+ (instancetype)rotateViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray showScale:(BOOL)showScale;
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray showScale:(BOOL)showScale;

+ (instancetype)rotateViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray describeArray:(NSArray *)describeArray showScale:(BOOL)showScale;
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray describeArray:(NSArray *)describeArray showScale:(BOOL)showScale;

- (void)startWave;
- (void)stopWave;

- (void)stopPushRefresh;

@end
