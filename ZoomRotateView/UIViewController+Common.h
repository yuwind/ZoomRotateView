//
//  UIViewController+Common.h
//  UIViewControllerCategory
//
//  Created by hxw on 16/8/11.
//  Copyright © 2016年 HXW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LayerLevelHight,
    LayerLevelLow,
} LayerLevel;

typedef struct RetryViewAttributes {
    __unsafe_unretained  UIColor *bgColor;
    __unsafe_unretained  NSString *imageName;
    __unsafe_unretained  NSString *text;
    __unsafe_unretained  UIColor *textColor;
    CGFloat fontSize;
} RetryView;

UIKIT_STATIC_INLINE RetryView retryViewMake(UIColor *bgColor,NSString *imageName, NSString *labelText ,UIColor *textColor, CGFloat fontSize)
{
    RetryView retryView = {bgColor, imageName, labelText, textColor, fontSize};
    return retryView;
}

typedef void(^retryEvent)();


@interface UIViewController (Common)

- (void)showWaitHud;
- (void)hideWaitHud;

- (void)showText:(NSString *)text;
- (void)showText:(NSString *)text interval:(NSTimeInterval)interval;

- (void)showRetryView:(RetryView)retryView buttonClick:(retryEvent)block;
- (void)showRetryView:(RetryView)retryView level:(LayerLevel)level buttonClick:(retryEvent)block;
- (void)hideRetryView;

@end
