//
//  UIViewController+MASAdditions.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ViewController+SM_MASAdditions.h"

#ifdef MAS_VIEW_CONTROLLER

@implementation MAS_VIEW_CONTROLLER (SM_MASAdditions)

- (SM_MASViewAttribute *)mas_topLayoutGuide {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (SM_MASViewAttribute *)mas_topLayoutGuideTop {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (SM_MASViewAttribute *)mas_topLayoutGuideBottom {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (SM_MASViewAttribute *)mas_bottomLayoutGuide {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (SM_MASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (SM_MASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[SM_MASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
