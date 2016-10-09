//
//  BQGiftManager.h
//  BQLiveSDKDemo
//
//  Created by isan on 28/09/2016.
//  Copyright © 2016 Tender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BQGift.h"

@interface BQGiftManager : NSObject


+ (BQGiftManager *) defaultManager;

/**
 从服务器获取所有礼物列表，存储到本地数据库
 */
- (void)getAllGiftsFromServer;


/**
 获取所有本地礼物

 @return 本地所有礼物
 */
- (NSArray *)getAllGiftsFromLocal;


/**
 通过网络获取到的最新的礼物列表更新本地的礼物列表，并下载需要下载资源的礼物

 @param remoteGifts 网络获取的最新礼物列表
 */
- (void)updateLocalGiftsWithRemoteGifts:(NSArray *)remoteGifts;


/**
 下载所有尚未下载的礼物资源
 */
- (void)downloadGifts;


/**
 下载礼物资源

 @param gifts 需要下载的礼物列表
 */
- (void)downloadGifts:(NSArray *)gifts;


/**
 删除gift

 @param gift 要删除的gift
 */
- (void)deleteGift:(BQGift *)gift;


/**
 获取礼物的资源的路径

 @param gift gift对象

 @return 礼物的资源的路径
 */
- (NSString *)pathForGift:(BQGift *)gift;
@end
