//
//  BQLAnimatedImageConfig.h
//  BMLiveSDKDemo
//
//  Created by Tender on 16/9/6.
//  Copyright © 2016年 Tender. All rights reserved.
//


/*
*  特效中 主播头像／昵称、发送礼物的用户的头像／昵称的配置相关类
*/

#ifndef BQLAnimatedImageConfig_h
#define BQLAnimatedImageConfig_h
#import <Foundation/Foundation.h>

@interface BQLImageConfig : NSObject

- (nullable instancetype)initWithDic:(nonnull NSDictionary *)dic;

@property (nullable, nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nullable, nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGFloat shadowX;
@property (nonatomic, assign) CGFloat shadowY;

@end

@interface BQLTextConfig : NSObject

- (nullable instancetype)initWithDic:(nonnull NSDictionary *)dic;
@property (nullable, nonatomic, strong) UIColor *color;
@property (nullable, nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nullable, nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGFloat shadowX;
@property (nonatomic, assign) CGFloat shadowY;

@end

struct BQLGiftFrameConfig {
    CGFloat scale;
    CGFloat rotate;
    CGFloat alpha;
    CGRect postion;
};

typedef struct BQLGiftFrameConfig BQLGiftFrameConfig;

@interface BQLAnimatedImageConfig: NSObject

@property (nonatomic, assign, readonly) NSUInteger frameCount;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) BOOL isStatic;

@property (nonatomic, assign, readonly) BOOL needHostAvatar;
@property (nonatomic, assign, readonly) BOOL needHostNickname;
@property (nonatomic, assign, readonly) BOOL needSenderAvatar;
@property (nonatomic, assign, readonly) BOOL needSenderNickname;

@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *subImageKeys;//帧辅图列表

@property (nullable, nonatomic, strong, readonly) BQLImageConfig *hostAvatarConfig;
@property (nullable, nonatomic, strong, readonly) BQLImageConfig *senderAvatarConfig;
@property (nullable, nonatomic, strong, readonly) BQLTextConfig *hostNickNameConfig;
@property (nullable, nonatomic, strong, readonly) BQLTextConfig *senderNickNameConfig;

- (nullable instancetype)initWithDictionyPath:(nonnull NSString *)path;

- (BQLGiftFrameConfig)getHostAvatarConfigWithFrame:(NSUInteger)frame;
- (BQLGiftFrameConfig)getSenderAvatarConfigWithFrame:(NSUInteger)frame;
- (BQLGiftFrameConfig)getHostNicknameConfigWithFrame:(NSUInteger)frame;
- (BQLGiftFrameConfig)getSenderNicknameConfigWithFrame:(NSUInteger)frame;

- (nonnull NSString *)mainPathWithFrame:(NSUInteger)frame;//帧主图的文件路径
- (nonnull NSString *)subImagePathWithKey:(nonnull NSString *)subImageKey;//帧辅图的文件路径

- (nullable UIImage *)subImageWithKey:(nonnull NSString *)subImageKey;//帧辅图
- (nullable BQLImageConfig *)getSubImageConfigWithKey:(nonnull NSString *)subImageKey;//帧辅图的配置信息
- (BQLGiftFrameConfig)getSubImageFrameConfigWithKey:(nonnull NSString *)subImageKey frame:(NSUInteger)frame;//帧辅图在特定帧的配置

@end

#endif /* BQLAnimatedImageConfig_h */
