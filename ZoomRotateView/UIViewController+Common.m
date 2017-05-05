//
//  UIViewController+Common.m
//  UIViewControllerCategory
//
//  Created by hxw on 16/8/11.
//  Copyright © 2016年 HXW. All rights reserved.
//

#import "UIViewController+Common.h"
#import <objc/runtime.h>

#define HUDWH 80
#define HUDT 0.2

#define ALERTMARGIN 15
#define ALERTTIME 0.5
#define ALERTFONT 17
#define ALERTINTERVAL 1.5

#define SWIDTH [UIScreen mainScreen].bounds.size.width
#define SHEIGHT [UIScreen mainScreen].bounds.size.height



static char * const hudViewKey = "hudViewKey";
static char * const retryViewKey = "retryViewKey";
static char * const retryBlockKey = "retryBlockKey";



@implementation UIViewController (Common)


- (void)showText:(NSString *)text
{
    [self showText:text interval:ALERTINTERVAL];
}
- (void)showText:(NSString *)text interval:(NSTimeInterval)interval
{
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:ALERTFONT]}];
    int labelLine = (int)(size.width / (SWIDTH * 2 / 3)) + 1;
    if (size.width > SWIDTH * 2 / 3) {
        size.width = SWIDTH * 2 / 3;
        size.height *= labelLine;
    }
    UIView *bgView = [[UIView alloc] init];
    bgView.layer.zPosition = 3.0f;
    [self.view addSubview:bgView];
    bgView.layer.cornerRadius = 8;
    bgView.clipsToBounds = YES;
    bgView.alpha = 0;
    bgView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    bgView.frame = CGRectMake(0, 0, size.width + 2 * ALERTMARGIN, size.height + 2 * ALERTMARGIN);
    bgView.center = CGPointMake(SWIDTH/2, SHEIGHT/2);
    
    UILabel *alert = [[UILabel alloc] init];
    alert.text = text;
    alert.numberOfLines = labelLine;
    alert.font = [UIFont boldSystemFontOfSize:ALERTFONT];
    alert.textColor = [UIColor whiteColor];
    alert.textAlignment = NSTextAlignmentCenter;
    
    alert.frame = CGRectMake(ALERTMARGIN,ALERTMARGIN, size.width, size.height);
    [bgView addSubview:alert];
    
    [UIView animateWithDuration:ALERTTIME animations:^{
        bgView.alpha = 1;
    }completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:ALERTTIME animations:^{
                bgView.alpha = 0;
            }completion:^(BOOL finished) {
                [bgView removeFromSuperview];
            }];
        });
    }];
}

- (void)showWaitHud
{
    self.view.userInteractionEnabled = NO;
    UIView *hudView = objc_getAssociatedObject(self, hudViewKey);
    if (hudView) return;
    hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HUDWH, HUDWH)];
    hudView.layer.cornerRadius = 10;
    hudView.clipsToBounds = YES;
    hudView.layer.zPosition = 2.0f;
    hudView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    hudView.alpha = 0.0f;
    hudView.center = CGPointMake(SWIDTH/2, SHEIGHT/2);
    [self.view addSubview:hudView];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]init];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activity.frame = hudView.bounds;
    [activity startAnimating];
    [hudView addSubview:activity];
    
    [UIView animateWithDuration:HUDT animations:^{
        hudView.alpha = 1;
    }];
    objc_setAssociatedObject(self, hudViewKey, hudView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)hideWaitHud
{
    self.view.userInteractionEnabled = YES;
    UIView *hudView = objc_getAssociatedObject(self, hudViewKey);
    if (!hudView) return;
    [UIView animateWithDuration:HUDT animations:^{
        hudView.alpha = 0;
    } completion:^(BOOL finished) {
        [hudView removeFromSuperview];
    }];
    hudView = nil;
    objc_setAssociatedObject(self, hudViewKey, hudView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showRetryView:(RetryView)retryView buttonClick:(retryEvent)block
{
    [self showRetryView:retryView level:LayerLevelHight buttonClick:block];
}

- (void)showRetryView:(RetryView)retryView level:(LayerLevel)level buttonClick:(retryEvent)block
{
    UIView *bgView = objc_getAssociatedObject(self, retryViewKey);
    if (bgView)return;
    if (block) {
        objc_setAssociatedObject(self, retryBlockKey, block,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    bgView = [[UIView alloc]initWithFrame:self.view.frame];
    bgView.backgroundColor = retryView.bgColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:retryView.imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(retryButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.center = CGPointMake(SWIDTH / 2, SHEIGHT / 2 -60);
    [bgView addSubview:button];
    
    UILabel *desc = [[UILabel alloc] init];
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 0;
    desc.text = retryView.text;
    desc.textColor = retryView.textColor;
    desc.font = [UIFont boldSystemFontOfSize:retryView.fontSize];
    
    CGRect frame = desc.frame;
    frame.size.width = SWIDTH * 2 / 3;
    frame.origin.y = CGRectGetMaxY(button.frame)+20;
    desc.frame = frame;
    [desc sizeToFit];
    CGPoint center = desc.center;
    center.x  = SWIDTH / 2;
    desc.center = center;
    [bgView addSubview:desc];
    if (level == LayerLevelLow) {
        [self.view insertSubview:bgView atIndex:self.view.subviews.count-1];
    }else
    {
        [self.view addSubview:bgView];
    }
    
    objc_setAssociatedObject(self, retryViewKey, bgView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hideRetryView
{
    UIView *bgView = objc_getAssociatedObject(self, retryViewKey);
    if (!bgView) return;
    [bgView removeFromSuperview];
    bgView = nil;
    objc_setAssociatedObject(self, retryViewKey, bgView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    retryEvent event = objc_getAssociatedObject(self, retryBlockKey);
    if (!event) return;
    event = nil;
    objc_setAssociatedObject(self, retryBlockKey, event,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)retryButtonClick
{
    retryEvent event = objc_getAssociatedObject(self, retryBlockKey);
    if (event) {
        event();
    }
}
@end
