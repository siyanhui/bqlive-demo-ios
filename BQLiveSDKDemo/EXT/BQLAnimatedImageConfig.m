//
//  BQLAnimatedImageConfig.m
//  BMLiveSDKDemo
//
//  Created by Tender on 16/9/6.
//  Copyright © 2016年 Tender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BQLAnimatedImageConfig.h"
#import "UIColor+BQLive.h"
#import <BQLiveSDK/BQLiveSDK.h>



@interface BQLAnimatedImageConfig ()

@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSString *dicPath;

@property (nonatomic, strong) BQLImageConfig *hostAvatarConfig;
@property (nonatomic, strong) BQLImageConfig *senderAvatarConfig;
@property (nonatomic, strong) BQLTextConfig *hostNickNameConfig;
@property (nonatomic, strong) BQLTextConfig *senderNickNameConfig;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSMutableDictionary *subImages;

@end

@implementation BQLAnimatedImageConfig

- (instancetype)initWithDictionyPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.dicPath = path;
        NSString *configPath = [path stringByAppendingPathComponent:@"config.txt"];
        NSData *data = [NSData dataWithContentsOfFile:configPath];
        self.dic = [BQLiveManager decodeConfigWithData:data];
        _giftGuid = [self.dic objectForKey:@"guid"];
        _needHostAvatar = [self.dic objectForKey:@"hostAvatar"] != nil;
        _needHostNickname = [self.dic objectForKey:@"hostNickName"] != nil;
        _needSenderAvatar = [self.dic objectForKey:@"senderAvatar"] != nil;
        _needSenderNickname = [self.dic objectForKey:@"senderNickName"] != nil;
        self.hostAvatarConfig = [self getHostAvatarConfig];
        self.senderAvatarConfig = [self getSenderAvatarConfig];
        self.hostNickNameConfig = [self getHostNicknameConfig];
        self.senderNickNameConfig = [self getSenderNicknameConfig];
        self.frameCount = [[self.dic objectForKey:@"frame"] integerValue];
        self.width = [[self.dic objectForKey:@"width"] floatValue];
        self.height = [[self.dic objectForKey:@"height"] floatValue];
        self.subImages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BQLImageConfig *)getHostAvatarConfig {
    if (_needHostAvatar) {
        NSDictionary *configDic = [self.dic objectForKey:@"hostAvatarConfig"];
        if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
            BQLImageConfig *config = [[BQLImageConfig alloc] initWithDic:configDic];
            return config;
        }
    }
    return nil;
}

- (BQLImageConfig *)getSenderAvatarConfig {
    if (_needSenderAvatar) {
        NSDictionary *configDic = [self.dic objectForKey:@"senderAvatarConfig"];
        if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
            BQLImageConfig *config = [[BQLImageConfig alloc] initWithDic:configDic];
            return config;
        }
    }
    return nil;
}

- (BQLTextConfig *)getHostNicknameConfig {
    if (_needHostNickname) {
        NSDictionary *configDic = [self.dic objectForKey:@"hostNickNameConfig"];
        if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
            BQLTextConfig *config = [[BQLTextConfig alloc] initWithDic:configDic];
            return config;
        }
    }
    return nil;
}

- (BQLTextConfig *)getSenderNicknameConfig {
    if (_needSenderNickname) {
        NSDictionary *configDic = [self.dic objectForKey:@"senderNickNameConfig"];
        if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
            BQLTextConfig *config = [[BQLTextConfig alloc] initWithDic:configDic];
            return config;
        }
    }
    return nil;
}

#pragma mark - Frame config

- (BQLGiftFrameConfig)getHostAvatarConfigWithFrame:(NSUInteger)frame {
    return [self getConfigWithFrame:frame key:@"hostAvatar"];
}

- (BQLGiftFrameConfig)getSenderAvatarConfigWithFrame:(NSUInteger)frame {
    return [self getConfigWithFrame:frame key:@"senderAvatar"];
}

- (BQLGiftFrameConfig)getHostNicknameConfigWithFrame:(NSUInteger)frame {
    return [self getConfigWithFrame:frame key:@"hostNickName"];
}

- (BQLGiftFrameConfig)getSenderNicknameConfigWithFrame:(NSUInteger)frame {
    return [self getConfigWithFrame:frame key:@"senderNickName"];
}

- (BQLGiftFrameConfig)getConfigWithFrame:(NSUInteger)frame key:(NSString *)key {
    NSArray *hostAvatarArray = [self.dic objectForKey:key];
    if (hostAvatarArray && hostAvatarArray.count > frame) {
        NSDictionary *frameDic = hostAvatarArray[frame];
        BQLGiftFrameConfig config;
        config.scale = ((NSNumber *)frameDic[@"scale"]).floatValue;
        config.rotate = ((NSNumber *)frameDic[@"rotate"]).floatValue;
        config.alpha = ((NSNumber *)frameDic[@"alpha"]).floatValue;
        CGFloat x = ((NSNumber *)frameDic[@"x"]).floatValue;
        CGFloat y = ((NSNumber *)frameDic[@"y"]).floatValue;
        CGFloat width = ((NSNumber *)frameDic[@"width"]).floatValue;
        CGFloat height = ((NSNumber *)frameDic[@"height"]).floatValue;
        config.postion = CGRectMake(x, y, width, height);
        return config;
    }else {
        BQLGiftFrameConfig config;
        return config;
    }
}

//帧主图的文件路径

- (NSString *)mainPathWithFrame:(NSUInteger)frame {
    NSArray *mainArray = [self.dic objectForKey:@"main"];
    NSString *fileName = @"";
    if (mainArray && frame < mainArray.count) {
        fileName = mainArray[frame];
    }else {
        fileName = [NSString stringWithFormat:@"%lu", (unsigned long)frame];
    }
    return [self.dicPath stringByAppendingPathComponent:fileName];
}

- (nonnull NSString *)subImagePathWithKey:(nonnull NSString *)subImageKey {
    return [self.dicPath stringByAppendingPathComponent:subImageKey];
}

- (nullable UIImage *)subImageWithKey:(nonnull NSString *)subImageKey {
    UIImage *image = [self.subImages objectForKey:subImageKey];
    if (image) {
        return image;
    }
    NSString *path = [self subImagePathWithKey:subImageKey];
    image = [UIImage imageWithContentsOfFile:path];
    [self.subImages setObject:image forKey:subImageKey];
    return image;

}

- (nullable BQLImageConfig *)getSubImageConfigWithKey:(nonnull NSString *)subImageKey {
    NSString *key = [NSString stringWithFormat:@"%@c", subImageKey];
    NSDictionary *configDic = [self.dic objectForKey:key];
    if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
        BQLImageConfig *config = [[BQLImageConfig alloc] initWithDic:configDic];
        return config;
    }
    return nil;
}

//帧辅图在特定帧的配置
- (BQLGiftFrameConfig)getSubImageFrameConfigWithKey:(nonnull NSString *)subImageKey frame:(NSUInteger)frame {
    NSString *key = [NSString stringWithFormat:@"%@f", subImageKey];
    NSArray *framConfigsArray = [self.dic objectForKey:key];
    if (framConfigsArray && framConfigsArray.count > frame) {
        NSDictionary *frameDic = framConfigsArray[frame];
        BQLGiftFrameConfig config;
        config.scale = ((NSNumber *)frameDic[@"scale"]).floatValue;
        config.rotate = ((NSNumber *)frameDic[@"rotate"]).floatValue;
        config.alpha = ((NSNumber *)frameDic[@"alpha"]).floatValue;
        CGFloat x = ((NSNumber *)frameDic[@"x"]).floatValue;
        CGFloat y = ((NSNumber *)frameDic[@"y"]).floatValue;
        CGFloat width = ((NSNumber *)frameDic[@"width"]).floatValue;
        CGFloat height = ((NSNumber *)frameDic[@"height"]).floatValue;
        config.postion = CGRectMake(x, y, width, height);
        return config;
    }else {
        BQLGiftFrameConfig config;
        return config;
    }
}


@end

@implementation BQLImageConfig

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        id borderColor = [dic objectForKey:@"borderColor"];
        if (borderColor != nil && [borderColor isKindOfClass:[NSString class]]) {
            NSString *borderColorString = (NSString *)borderColor;
            self.borderColor = [UIColor bml_colorWithHexColorString:borderColorString];
        }
        id borderNumber = [dic objectForKey:@"borderWidth"];
        if (borderNumber != nil && [borderNumber isKindOfClass:[NSNumber class]]) {
            self.borderWidth = ((NSNumber *)borderNumber).floatValue;
        }
        id cornerRadiusNumber = [dic objectForKey:@"cornerRadius"];
        if (cornerRadiusNumber != nil && [cornerRadiusNumber isKindOfClass:[NSNumber class]]) {
            self.cornerRadius = ((NSNumber *)cornerRadiusNumber).floatValue;
        }
        id shadowColor = [dic objectForKey:@"shadowColor"];
        if (shadowColor != nil && [shadowColor isKindOfClass:[NSString class]]) {
            NSString *shadowColorString = (NSString *)shadowColor;
            self.shadowColor = [UIColor bml_colorWithHexColorString:shadowColorString];
        }

        id shadowX = [dic objectForKey:@"shadowX"];
        if (shadowX != nil && [shadowX isKindOfClass:[NSNumber class]]) {
            self.shadowX = ((NSNumber *)shadowX).floatValue;
        }

        id shadowY = [dic objectForKey:@"shadowY"];
        if (shadowY != nil && [shadowY isKindOfClass:[NSNumber class]]) {
            self.shadowY = ((NSNumber *)shadowY).floatValue;
        }

        id shadowBlur = [dic objectForKey:@"shadowBlur"];
        if (shadowBlur != nil && [shadowBlur isKindOfClass:[NSNumber class]]) {
            self.shadowBlur = ((NSNumber *)shadowBlur).floatValue;
        }

    }
    return self;
}

@end


@implementation BQLTextConfig

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        id borderColor = [dic objectForKey:@"borderColor"];
        if (borderColor != nil && [borderColor isKindOfClass:[NSString class]]) {
            NSString *borderColorString = (NSString *)borderColor;
            self.borderColor = [UIColor bml_colorWithHexColorString:borderColorString];
        }

        id textColor = [dic objectForKey:@"color"];
        if (textColor != nil && [textColor isKindOfClass:[NSString class]]) {
            NSString *colorString = (NSString *)textColor;
            self.color = [UIColor bml_colorWithHexColorString:colorString];
        }

        id borderNumber = [dic objectForKey:@"borderWidth"];
        if (borderNumber != nil && [borderNumber isKindOfClass:[NSNumber class]]) {
            self.borderWidth = ((NSNumber *)borderNumber).floatValue;
        }

        id alignmentNumber = [dic objectForKey:@"alignment"];
        if (alignmentNumber != nil && [alignmentNumber isKindOfClass:[NSNumber class]]) {
            int alignValue = ((NSNumber *)alignmentNumber).intValue;
            self.textAlignment = NSTextAlignmentCenter;
            if (alignValue == 0) {
                self.textAlignment = NSTextAlignmentLeft;
            }else if (alignValue == 2) {
                self.textAlignment = NSTextAlignmentRight;
            }
        }

        id shadowColor = [dic objectForKey:@"shadowColor"];
        if (shadowColor != nil && [shadowColor isKindOfClass:[NSString class]]) {
            NSString *shadowColorString = (NSString *)shadowColor;
            self.shadowColor = [UIColor bml_colorWithHexColorString:shadowColorString];
        }

        id shadowX = [dic objectForKey:@"shadowX"];
        if (shadowX != nil && [shadowX isKindOfClass:[NSNumber class]]) {
            self.shadowX = ((NSNumber *)shadowX).floatValue;
        }

        id shadowY = [dic objectForKey:@"shadowY"];
        if (shadowY != nil && [shadowY isKindOfClass:[NSNumber class]]) {
            self.shadowY = ((NSNumber *)shadowY).floatValue;
        }

        id shadowBlur = [dic objectForKey:@"shadowBlur"];
        if (shadowBlur != nil && [shadowBlur isKindOfClass:[NSNumber class]]) {
            self.shadowBlur = ((NSNumber *)shadowBlur).floatValue;
        }
        
    }
    return self;
}

@end
