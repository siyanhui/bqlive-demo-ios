//
//  BMAnimatedImage.h
//  BMLiveSDKDemo
//
//  Created by Tender on 16/9/2.
//  Copyright © 2016年 Tender. All rights reserved.
//

#ifndef BMAnimatedImage_h
#define BMAnimatedImage_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BQLAnimatedImageConfig.h"

extern const NSTimeInterval kBMAnimatedImageDelayTimeIntervalMinimum;

@protocol BMLAnimatedImageDataSource <NSObject>

- (UIImage *)getHostAvatar;//主播

- (NSString *)getHostNickname;

- (UIImage *)getSenderAvatar;//送礼物的用户

- (NSString *)getSenderNickname;

@end

@interface BQLAnimatedImage: NSObject

/*
 *  礼物特效的总帧数
 */

@property (nonatomic, assign, readonly) NSUInteger frameCount;

/*
 *  礼物特效的第一帧图片
 */
@property (nonatomic, strong, readonly) UIImage *posterImage;

/*
 *  当前缓存的帧数
 */
@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeCurrent;

/*
 * 特效播放次数
 */
@property (nonatomic, assign) NSUInteger loopCount;

/*
 * 每一帧的延时数据
 */
@property (nonatomic, strong, readonly) NSDictionary *delayTimesForIndexes;

/*
 * 提供特效需要的资源
 */
@property (nonatomic, weak) id<BMLAnimatedImageDataSource> dataSource;

/*
 * 取特定帧的图片
 */
- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index;

/*
 * 初始化函数
 */
+ (instancetype)animatedImageWithConfig:(BQLAnimatedImageConfig *)config dataSource:(id<BMLAnimatedImageDataSource>)dataSource;

@end

@interface BMWeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end

#endif /* BMAnimatedImageView_h */
