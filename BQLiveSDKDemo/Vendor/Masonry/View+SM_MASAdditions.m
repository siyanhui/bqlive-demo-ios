//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+SM_MASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (SM_MASAdditions)

- (NSArray *)mas_makeConstraints:(void(^)(SM_MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SM_MASConstraintMaker *constraintMaker = [[SM_MASConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_updateConstraints:(void(^)(SM_MASConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SM_MASConstraintMaker *constraintMaker = [[SM_MASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas_remakeConstraints:(void(^)(SM_MASConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SM_MASConstraintMaker *constraintMaker = [[SM_MASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (SM_MASViewAttribute *)mas_left {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (SM_MASViewAttribute *)mas_top {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (SM_MASViewAttribute *)mas_right {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (SM_MASViewAttribute *)mas_bottom {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (SM_MASViewAttribute *)mas_leading {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (SM_MASViewAttribute *)mas_trailing {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (SM_MASViewAttribute *)mas_width {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (SM_MASViewAttribute *)mas_height {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (SM_MASViewAttribute *)mas_centerX {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (SM_MASViewAttribute *)mas_centerY {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (SM_MASViewAttribute *)mas_baseline {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (SM_MASViewAttribute *(^)(NSLayoutAttribute))mas_attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if TARGET_OS_IPHONE || TARGET_OS_TV

- (SM_MASViewAttribute *)mas_leftMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (SM_MASViewAttribute *)mas_rightMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (SM_MASViewAttribute *)mas_topMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (SM_MASViewAttribute *)mas_bottomMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (SM_MASViewAttribute *)mas_leadingMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (SM_MASViewAttribute *)mas_trailingMargin {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (SM_MASViewAttribute *)mas_centerXWithinMargins {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (SM_MASViewAttribute *)mas_centerYWithinMargins {
    return [[SM_MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#pragma mark - associated properties

- (id)mas_key {
    return objc_getAssociatedObject(self, @selector(mas_key));
}

- (void)setMas_key:(id)key {
    objc_setAssociatedObject(self, @selector(mas_key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas_closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = nil;

    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
