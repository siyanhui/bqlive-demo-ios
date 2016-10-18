//
//  BQLiveManager.h
//
//  Created by Tender on 16/9/6.
//  Copyright © 2016年 Tender. All rights reserved.
//

#ifndef BQLiveManager_h
#define BQLiveManager_h
#import <Foundation/Foundation.h>

@interface BQLiveManager : NSObject

@property (nonatomic, copy, nonnull) NSString *appId;
@property (nonatomic, copy, nonnull) NSString *appSecret;

//第三方平台初始化信息
@property (nonatomic, copy, nonnull) NSString *platformId;
@property (nonatomic, copy, nonnull) NSString *appKey;

@property (nonatomic, copy, nullable) NSString *userId;

+ (nonnull instancetype)defaultManager;

/**
 *  初始化 SDK
 *  @param appId     申请的app id
 *  @param secret    申请的app secret
 *  99d7350c3741e472ffa5b44983a60e2b03f1bbb0
 */
- (void)setAppId:(nonnull NSString *)appId secret:(nonnull NSString *)secret;


/**
 用第三方平台信息初始化SDK

 @param appkey     第三方申请的appKey
 @param platformId 第三方平台id
 */
- (void)setAppkey:(nonnull NSString *)appkey platformId:(nonnull NSString *)platformId;

#pragma mark - Decode Gift Resource
/**
 *  解码礼物动画的配置文件
 *  @param data 配置文件的内容
 */
+ (nonnull NSDictionary *)decodeConfigWithData:(nonnull NSData *)data;

/**
 *  解码礼物动画的资源文件， 转存的路径不可与原文件路径相同
 *  @param path 文件路径
 *  @param toPath 转存的路径
 */
+ (void)decodeGiftResourceWithPath:(nonnull NSString *)path toPath:(nonnull NSString *)toPath error:( NSError * _Nullable * _Nullable)error;


#pragma mark - Log Event

/**
 *  礼物发送事件统计
 *  @param userId 观众的ID
 *  @param userName 观众昵称
 *  @param giftId 礼物ID
 *  @param giftName 礼物名称
 *  @param giftPrice 礼物价格
 *  @param hostId 主播的ID
 *  @param hostName 主播昵称
 */
+ (void)logSendGiftWithUserId:(nonnull NSString *)userId userName:(nullable NSString *)userName giftId:(nonnull NSString *)giftId giftName:(nullable NSString *)giftName giftPrice:(nullable NSString *)giftPrice toHostId:(nonnull NSString *)hostId hostName:(nullable NSString *)hostName;

/**
 *  礼物播放事件统计
 *  @param userId 观众的ID
 *  @param userName 观众昵称
 *  @param giftId 礼物ID
 *  @param giftName 礼物名称
 *  @param giftPrice 礼物价格
 *  @param hostId 主播的ID
 *  @param hostName 主播昵称
 */
+ (void)logViewGiftWithUserId:(nonnull NSString *)userId userName:(nullable NSString *)userName giftId:(nonnull NSString *)giftId giftName:(nullable NSString *)giftName giftPrice:(nullable NSString *)giftPrice toHostId:(nonnull NSString *)hostId hostName:(nullable NSString *)hostName;

/**
 首次下载礼物事件统计
 *  @param userId 观众的ID
 *  @param userName 观众昵称
 *  @param giftId 礼物ID
 *  @param giftName 礼物名称
 *  @param giftPrice 礼物价格
 */
+ (void)logDownloadGiftWithUserId:(nonnull NSString *)userId userName:(nullable NSString *)userName giftId:(nonnull NSString *)giftId giftName:(nullable NSString *)giftName giftPrice:(nullable NSString *)giftPrice;

/**
 更新礼物事件统计
 *  @param userId 观众的ID
 *  @param userName 观众昵称
 *  @param giftId 礼物ID
 *  @param giftName 礼物名称
 *  @param giftPrice 礼物价格
 */
+ (void)logUpdateGiftWithUserId:(nonnull NSString *)userId userName:(nullable NSString *)userName giftId:(nonnull NSString *)giftId giftName:(nullable NSString *)giftName giftPrice:(nullable NSString *)giftPrice;


@end


#endif /* BQLiveManager_h */
