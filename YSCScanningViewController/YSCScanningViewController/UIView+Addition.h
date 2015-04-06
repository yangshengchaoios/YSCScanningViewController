//
//  UIView+Addition.h
//  YSCKit
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>

#define WeakSelfType __weak __typeof(&*self)

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)
#define XIB_WIDTH                       640.0f

#define AUTOLAYOUT_SCALE                (SCREEN_WIDTH / XIB_WIDTH)          //缩放比例 (当前屏幕的真实宽度point / xib布局的宽度point)
#define AUTOLAYOUT_LENGTH(x)            ((x) * AUTOLAYOUT_SCALE)
#define AUTOLAYOUT_FONT(f)              ([UIFont systemFontOfSize:((f) * AUTOLAYOUT_SCALE)])

@interface UIView (Addition)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

/**
 *  移除view上所有的手势操作
 */
- (void)removeAllGestureRecognizers;
/**
 *  移除view上所有的子view
 */
- (void)removeAllSubviews;
/**
 *  移除view(包括subviews)上所有constraints
 */
- (void)removeAllConstraints;
/**
 *  隐藏所有子view
 */
- (void)hideAllSubviews;


#pragma mark - view边框调整
+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius;
- (void)makeRoundWithRadius:(CGFloat)radius;
+ (void)makeBorderForView:(UIView *)view withColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width;


#pragma mark - 递归遍历所有子view

+ (void)resetFontSizeOfView:(UIView *)view;
- (void)resetFontSizeOfView;

+ (void)resetConstraintOfView:(UIView *)view;
- (void)resetConstraintOfView;

@end
