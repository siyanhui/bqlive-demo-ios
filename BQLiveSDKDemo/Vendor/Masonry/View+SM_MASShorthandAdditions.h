//
//  UIView+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+SM_MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas_' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface MAS_VIEW (SM_MASShorthandAdditions)

@property (nonatomic, strong, readonly) SM_MASViewAttribute *left;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *top;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *right;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *bottom;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *leading;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *trailing;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *width;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *height;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *centerX;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *centerY;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *baseline;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if TARGET_OS_IPHONE || TARGET_OS_TV

@property (nonatomic, strong, readonly) SM_MASViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *topMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) SM_MASViewAttribute *centerYWithinMargins;

#endif

- (NSArray *)makeConstraints:(void(^)(SM_MASConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(SM_MASConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(SM_MASConstraintMaker *make))block;

@end

#define MAS_ATTR_FORWARD(attr)  \
- (MASViewAttribute *)attr {    \
    return [self mas_##attr];   \
}

@implementation MAS_VIEW (SM_MASShorthandAdditions)

MAS_ATTR_FORWARD(top);
MAS_ATTR_FORWARD(left);
MAS_ATTR_FORWARD(bottom);
MAS_ATTR_FORWARD(right);
MAS_ATTR_FORWARD(leading);
MAS_ATTR_FORWARD(trailing);
MAS_ATTR_FORWARD(width);
MAS_ATTR_FORWARD(height);
MAS_ATTR_FORWARD(centerX);
MAS_ATTR_FORWARD(centerY);
MAS_ATTR_FORWARD(baseline);

#if TARGET_OS_IPHONE || TARGET_OS_TV

MAS_ATTR_FORWARD(leftMargin);
MAS_ATTR_FORWARD(rightMargin);
MAS_ATTR_FORWARD(topMargin);
MAS_ATTR_FORWARD(bottomMargin);
MAS_ATTR_FORWARD(leadingMargin);
MAS_ATTR_FORWARD(trailingMargin);
MAS_ATTR_FORWARD(centerXWithinMargins);
MAS_ATTR_FORWARD(centerYWithinMargins);

#endif

- (SM_MASViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas_attribute];
}

- (NSArray *)makeConstraints:(void(^)(SM_MASConstraintMaker *))block {
    return [self mas_makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(^)(SM_MASConstraintMaker *))block {
    return [self mas_updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(^)(SM_MASConstraintMaker *))block {
    return [self mas_remakeConstraints:block];
}

@end

#endif
