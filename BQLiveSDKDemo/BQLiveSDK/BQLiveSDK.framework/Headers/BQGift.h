//
//  BQGift.h
//  BQLiveSDKDemo
//
//  Created by isan on 28/09/2016.
//  Copyright © 2016 Tender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BQGift : NSObject

/**
 礼物id
 */
@property(nonatomic, strong) NSString *guid;

/**
 礼物名称
 */
@property(nonatomic, strong) NSString *name;

/**
 礼物价格
 */
@property(nonatomic, strong) NSString *price;

/**
 附加属性  扩展
 */
@property(nonatomic, strong) NSString *extra;


/**
 迷你图的URL，尺寸为32x32的png
 */
@property(nonatomic, strong) NSString *mini;


/**
 缩略图的URL，尺寸为240x240的png
 */
@property(nonatomic, strong) NSString *thumb;


/**
 缩略图的URL，尺寸为240x240的png
 */
@property(nonatomic, strong) NSString *preview;


/**
 礼物动画素材（zip）的URL
 */
@property(nonatomic, strong) NSString *animatedData;

/**
 礼物素材的宽度,单位是像素
 */
@property(nonatomic) int width;

/**
  礼物素材的高度,单位是像素
 */
@property(nonatomic) int height;

/**
 礼物动画时长，单位为毫秒
 */
@property(nonatomic) NSTimeInterval duration;

/**
 礼物创建时间
 */
@property(nonatomic) NSTimeInterval createdTime;

/**
 礼物更新的最新时间，用于判断客户端是否需要对本地的礼物做更新（通过animatedData的地址是否更新来判断是否需要重新下载资源）
 */
@property(nonatomic) NSTimeInterval lastUpdatedTime;


/**
 更新BQGift
 @param dic  对应BQGift的property的key value
 */
- (void)updateWithKeyValues:(NSDictionary *)dic;

@end
