//
//  BQGiftManager.h
//  BQLiveSDKDemo
//
//  Created by isan on 28/09/2016.
//  Copyright © 2016 Tender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BQGift.h"

typedef void (^BQ_GetAllGiftsSuccess)(NSArray<BQGift *> * _Nullable gifts);
typedef void (^BQ_GetAllGiftsFail)( NSError * _Nonnull error);
typedef void (^BQ_GiftsDownloadedFinish)( NSArray<BQGift *> * _Nullable failGifts);
typedef void (^BQ_GiftDeleteFinish)(NSError * _Nullable error);

@interface BQGiftManager : NSObject


+ (nonnull BQGiftManager *) defaultManager;

/**
 传入用户的信息用于记录礼物的下载更新情况
 */
- (void)setUserId:(nonnull NSString *)userId userName:(nonnull NSString *)userName;

/**
 从服务器获取所有礼物列表
 */
- (void)getAllGiftsFromServer: (nullable BQ_GetAllGiftsSuccess)success fail: (nullable BQ_GetAllGiftsFail)fail;


/**
 获取所有本地礼物
 */
- (void)getAllGiftsFromLocal: (nullable BQ_GetAllGiftsSuccess)success fail: (nullable BQ_GetAllGiftsFail)fail;


/**
 下载礼物资源(这里传入希望下载到本地的礼物列表)

 @param gifts 需要下载的礼物列表
 */
- (void)downloadGifts:(nonnull NSArray *)gifts finish:(nullable BQ_GiftsDownloadedFinish) finish;


/**
 删除gift

 @param gift 要删除的gift
 */
- (void)deleteGift:(nonnull BQGift *)gift finish:(nullable BQ_GiftDeleteFinish)finish;


/**
 获取礼物的资源的路径

 @param gift gift对象

 @return 礼物的资源的路径
 */
- (nullable NSString *)pathForGift:(nonnull BQGift *)gift;
@end
