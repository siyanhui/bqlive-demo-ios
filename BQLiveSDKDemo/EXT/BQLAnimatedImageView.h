//
//  BQLAnimatedImageView.h
//  BMLiveSDKDemo
//
//    特效中的展示控件
//
//  Created by Tender on 16/9/2.
//  Copyright © 2016年 Tender. All rights reserved.
//

#ifndef BQLAnimatedImageView_h
#define BQLAnimatedImageView_h

#import <Foundation/Foundation.h>
#import "BQLAnimatedImage.h"
#import <UIKit/UIKit.h>



@class BQLAnimatedImageView;

@protocol BMLAnimatedImageViewDelegate <NSObject>

#pragma mark - Life Cycle
@optional

- (void)giftResourceReady:(BQLAnimatedImageView *)aImageView;

- (void)giftAnimationDidPlay:(BQLAnimatedImageView *)aImageView;

- (void)giftAnimationDidFinish:(BQLAnimatedImageView *)aImageView;

@end

@interface BQLAnimatedImageView: UIImageView

@property (nonatomic, strong) BQLAnimatedImage *animatedImage;
@property (nonatomic, copy) void(^loopCompletionBlock)(NSUInteger loopCountRemaining);

@property (nonatomic, strong, readonly) UIImage *currentFrame;
@property (nonatomic, assign, readonly) NSUInteger currentFrameIndex;

@property (nonatomic, copy) NSString *runLoopMode;

@property (nonatomic, weak) id<BMLAnimatedImageViewDelegate> delegate;

@end

#endif /* BQLAnimatedImageView_h */
