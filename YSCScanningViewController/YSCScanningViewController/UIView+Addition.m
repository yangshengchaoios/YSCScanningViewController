//
//  UIView+Addition.m
//  YSCKit
//
//  Created by  YangShengchao on 14-7-1.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


- (void)removeAllGestureRecognizers {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }    
}

- (void)removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)removeAllConstraints {
    for (NSLayoutConstraint *constraint in self.constraints) {
#if __PureLayout_MinBaseSDK_iOS_8_0
        if ([self respondsToSelector:@selector(setActive:)]) {
            constraint.active = NO;
        }
#endif /* __PureLayout_MinBaseSDK_iOS_8_0 */
        
        if (constraint.firstItem) {
            [constraint.firstItem removeConstraint:constraint];
        }
        if (constraint.secondItem) {
            [constraint.secondItem removeConstraint:constraint];
        }
    }
    for (UIView *subView in self.subviews) {
        [subView removeAllConstraints];
    }
}
 

#pragma mark - view边框调整
+ (void)makeCircleForView:(UIView *)view {
    if (nil == view) {
        return;
    }
    [view makeCircleView];
}
- (void)makeCircleView {
    [self makeRoundWithRadius:self.bounds.size.width / 2.0];
}

+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius {
    if (nil == view) {
        return;
    }
    [view makeRoundWithRadius:radius];
}
- (void)makeRoundWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
+ (void)makeBorderForView:(UIView *)view withColor:(UIColor *)color borderWidth:(CGFloat)width {
    if (nil == view) {
        return;
    }
    [view makeBorderWithColor:color borderWidth:width];
}
- (void)makeBorderWithColor:(UIColor *)color borderWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = AUTOLAYOUT_LENGTH(width);
}




#pragma mark - 递归遍历所有子view

- (void)resetFontSizeOfView {
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.font = AUTOLAYOUT_FONT(label.font.pointSize);
        }
        else if ([subview isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.font = AUTOLAYOUT_FONT(button.titleLabel.font.pointSize);
        }
        else if ([subview isMemberOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.font = AUTOLAYOUT_FONT(textField.font.pointSize);
        }
        else if ([subview isMemberOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)subview;
            textView.font = AUTOLAYOUT_FONT(textView.font.pointSize);
        }
        [subview resetFontSizeOfView];
    }
}

+ (void)resetConstraintOfView:(UIView *)view {
    if (nil == view) {
        return;
    }
    [view resetConstraintOfView];
}
- (void)resetConstraintOfView {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.constant > 0) {
            constraint.constant = AUTOLAYOUT_LENGTH(constraint.constant);
        }
    }
    
    if ([self.subviews count] > 0) {
        for (UIView *subView in self.subviews) {
            [subView resetConstraintOfView];
        }
    }
}

@end
