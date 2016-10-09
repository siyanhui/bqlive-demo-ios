//
//  BMAnimatedImageView.m
//  BMLiveSDKDemo
//
//  Created by Tender on 16/9/2.
//  Copyright © 2016年 Tender. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BQLAnimatedImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreText/CoreText.h>


// From vm_param.h, define for iOS 8.0 or higher to build on device.
#ifndef BYTE_SIZE
#define BYTE_SIZE 8 // byte size in bits
#endif

#define MEGABYTE (1024 * 1024)

const NSTimeInterval kBMAnimatedImageDelayTimeIntervalMinimum = 0.02;

typedef NS_ENUM(NSUInteger, BMAnimatedImageDataSizeCategory) {
    BMAnimatedImageDataSizeCategoryAll = 10,       // All frames permanently in memory (be nice to the CPU)
    BMAnimatedImageDataSizeCategoryDefault = 75,   // A frame cache of default size in memory (usually real-time performance and keeping low memory profile)
    BMAnimatedImageDataSizeCategoryOnDemand = 250, // Only keep one frame at the time in memory (easier on memory, slowest performance)
    BMAnimatedImageDataSizeCategoryUnsupported     // Even for one frame too large, computer says no.
};

typedef NS_ENUM(NSUInteger, BMAnimatedImageFrameCacheSize) {
    BMAnimatedImageFrameCacheSizeNoLimit = 2,
    BMAnimatedImageFrameCacheSizeLowMemory = 2,              // The minimum frame cache size; this will produce frames on-demand.
    BMAnimatedImageFrameCacheSizeGrowAfterMemoryWarning = 2, // If we can produce the frames faster than we consume, one frame ahead will already result in a stutter-free playback.
    BMAnimatedImageFrameCacheSizeDefault = 5                 // Build up a comfy buffer window to cope with CPU hiccups etc.
};


@interface BQLAnimatedImage ()

@property (nonatomic, assign) NSUInteger frameCacheSizeMax;

@property (nonatomic, assign, readonly) NSUInteger frameCacheSizeOptimal;
@property (nonatomic, assign) NSUInteger frameCacheSizeMaxInternal;
@property (nonatomic, assign) NSUInteger requestedFrameIndex;
@property (nonatomic, assign, readonly) NSUInteger posterImageFrameIndex;
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedFramesForIndexes;
@property (nonatomic, strong, readonly) NSMutableIndexSet *cachedFrameIndexes;
@property (nonatomic, strong, readonly) NSMutableIndexSet *requestedFrameIndexes;
@property (nonatomic, strong, readonly) NSIndexSet *allFramesIndexSet;

@property (nonatomic, strong, readonly) dispatch_queue_t serialQueue;

#pragma mark gift resource
@property (nonatomic, strong) UIImage *hostAvatar;
@property (nonatomic, strong) NSString *hostNickname;
@property (nonatomic, strong) UIImage *senderAvatar;
@property (nonatomic, strong) NSString *senderNickname;

@property (nonatomic, strong) BQLAnimatedImageConfig *giftConfig;

@end

@implementation BQLAnimatedImage

#pragma mark - Accessors
#pragma mark Public

- (NSUInteger)frameCacheSizeCurrent
{
    NSUInteger frameCacheSizeCurrent = self.frameCacheSizeOptimal;

    if (self.frameCacheSizeMax > BMAnimatedImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMax);
    }

    if (self.frameCacheSizeMaxInternal > BMAnimatedImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMaxInternal);
    }

    return frameCacheSizeCurrent;
}


- (void)setFrameCacheSizeMax:(NSUInteger)frameCacheSizeMax
{
    if (_frameCacheSizeMax != frameCacheSizeMax) {

        BOOL willFrameCacheSizeShrink = (frameCacheSizeMax < self.frameCacheSizeCurrent);

        _frameCacheSizeMax = frameCacheSizeMax;

        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}


#pragma mark Private

- (void)setFrameCacheSizeMaxInternal:(NSUInteger)frameCacheSizeMaxInternal
{
    if (_frameCacheSizeMaxInternal != frameCacheSizeMaxInternal) {

        BOOL willFrameCacheSizeShrink = (frameCacheSizeMaxInternal < self.frameCacheSizeCurrent);

        _frameCacheSizeMaxInternal = frameCacheSizeMaxInternal;

        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}



- (instancetype)init {
    self = [super init];
    return self;
}

- (void)initWithAnimatedImageConfig:(BQLAnimatedImageConfig *)config optimalFrameCacheSize:(NSUInteger)optimalFrameCacheSize {
    _giftConfig = config;

    // Initialize internal data structures
    _cachedFramesForIndexes = [[NSMutableDictionary alloc] init];
    _cachedFrameIndexes = [[NSMutableIndexSet alloc] init];
    _requestedFrameIndexes = [[NSMutableIndexSet alloc] init];

    _loopCount = 0;

    [self loadGiftResource];

    size_t imageCount = _giftConfig.frameCount;
    NSUInteger skippedFrameCount = 0;
    NSMutableDictionary *delayTimesForIndexesMutable = [NSMutableDictionary dictionaryWithCapacity:imageCount];
    for (size_t i = 0; i < imageCount; i++) {
        @autoreleasepool {

            if (!self.posterImage) {
                UIImage *image = [self imageAtIndex:i];
                _posterImage = image;
                _posterImageFrameIndex = i;
                [self.cachedFramesForIndexes setObject:self.posterImage forKey:@(self.posterImageFrameIndex)];
                [self.cachedFrameIndexes addIndex:self.posterImageFrameIndex];
            }

            NSNumber *delayTime = @0.08;
            const NSTimeInterval kDelayTimeIntervalDefault = 0.1;
            if ([delayTime floatValue] < ((float)kBMAnimatedImageDelayTimeIntervalMinimum - FLT_EPSILON)) {
                delayTime = @(kDelayTimeIntervalDefault);
            }
            delayTimesForIndexesMutable[@(i)] = delayTime;
        }
    }
    _delayTimesForIndexes = [delayTimesForIndexesMutable copy];
    _frameCount = imageCount;

    //根据每帧图片占用的内存，选择合适的缓存帧数
    if (optimalFrameCacheSize == 0) {
        CGFloat animatedImageDataSize = CGImageGetBytesPerRow(self.posterImage.CGImage) * self.posterImage.size.height * (self.frameCount - skippedFrameCount) / MEGABYTE;
        if (animatedImageDataSize <= BMAnimatedImageDataSizeCategoryAll) {
            _frameCacheSizeOptimal = self.frameCount;
        } else if (animatedImageDataSize <= BMAnimatedImageDataSizeCategoryDefault) {
            _frameCacheSizeOptimal = BMAnimatedImageFrameCacheSizeDefault;
        } else {
            _frameCacheSizeOptimal = BMAnimatedImageFrameCacheSizeLowMemory;
        }
    } else {
        _frameCacheSizeOptimal = optimalFrameCacheSize;
    }
    _frameCacheSizeOptimal = MIN(_frameCacheSizeOptimal, self.frameCount);

    _allFramesIndexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.frameCount)];
}


+ (instancetype)animatedImageWithConfig:(BQLAnimatedImageConfig *)config dataSource:(id<BMLAnimatedImageDataSource>)dataSource {
    BQLAnimatedImage *animatedImage =  [[BQLAnimatedImage alloc] init];
    animatedImage.dataSource = dataSource;
    [animatedImage initWithAnimatedImageConfig:config optimalFrameCacheSize:0];
    return animatedImage;
}


#pragma mark - Public Methods

- (UIImage *)imageLazilyCachedAtIndex:(NSUInteger)index
{
    if (index >= self.frameCount) {
        return nil;
    }

    self.requestedFrameIndex = index;

    if ([self.cachedFrameIndexes count] < self.frameCount) {

        NSMutableIndexSet *frameIndexesToAddToCacheMutable = [self frameIndexesToCache];
        [frameIndexesToAddToCacheMutable removeIndexes:self.cachedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndexes:self.requestedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndex:self.posterImageFrameIndex];
        NSIndexSet *frameIndexesToAddToCache = [frameIndexesToAddToCacheMutable copy];

        if ([frameIndexesToAddToCache count] > 0) {
            [self addFrameIndexesToCache:frameIndexesToAddToCache];
        }
    }

    UIImage *image = self.cachedFramesForIndexes[@(index)];

    [self purgeFrameCacheIfNeeded];

    return image;
}


- (void)addFrameIndexesToCache:(NSIndexSet *)frameIndexesToAddToCache
{

    NSRange firstRange = NSMakeRange(self.requestedFrameIndex, self.frameCount - self.requestedFrameIndex);
    NSRange secondRange = NSMakeRange(0, self.requestedFrameIndex);

    [self.requestedFrameIndexes addIndexes:frameIndexesToAddToCache];

    if (!self.serialQueue) {
        _serialQueue = dispatch_queue_create("com.siyanhui.framecachingqueue", DISPATCH_QUEUE_SERIAL);
    }

    BQLAnimatedImage * __weak weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        void (^frameRangeBlock)(NSRange, BOOL *) = ^(NSRange range, BOOL *stop) {
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {

                UIImage *image = [weakSelf imageAtIndex:i];

                if (image && weakSelf) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.cachedFramesForIndexes[@(i)] = image;
                        [weakSelf.cachedFrameIndexes addIndex:i];
                        [weakSelf.requestedFrameIndexes removeIndex:i];
                    });
                }
            }
        };

        [frameIndexesToAddToCache enumerateRangesInRange:firstRange options:0 usingBlock:frameRangeBlock];
        [frameIndexesToAddToCache enumerateRangesInRange:secondRange options:0 usingBlock:frameRangeBlock];
    });
}


#pragma mark - Private Methods
#pragma mark Frame Loading


- (UIImage *)imageAtIndex:(NSUInteger)index
{
    UIImage *image = nil;
    NSLog(@"decode start = %lu", (unsigned long)index);
    NSString *filePrePath = [self.giftConfig mainPathWithFrame:index];
    NSString *imagePath = [filePrePath stringByAppendingString:@"-a.jpg"];
    NSString *maskPath = [filePrePath stringByAppendingString:@"-b.jpg"];
    CGContextRef bitmapRef = [self bitmapForDraw];
    if (bitmapRef) {
        image = [self predrawnImageWithContext:bitmapRef imagePath:imagePath maskPath:maskPath frame:index];
    }
    NSLog(@"decode end = %lu", (unsigned long)index);
    return image;
}


#pragma mark Frame Caching

- (NSMutableIndexSet *)frameIndexesToCache
{
    NSMutableIndexSet *indexesToCache = nil;
    if (self.frameCacheSizeCurrent == self.frameCount) {
        indexesToCache = [self.allFramesIndexSet mutableCopy];
    } else {
        indexesToCache = [[NSMutableIndexSet alloc] init];

        NSUInteger firstLength = MIN(self.frameCacheSizeCurrent, self.frameCount - self.requestedFrameIndex);
        NSRange firstRange = NSMakeRange(self.requestedFrameIndex, firstLength);
        [indexesToCache addIndexesInRange:firstRange];
        NSUInteger secondLength = self.frameCacheSizeCurrent - firstLength;
        if (secondLength > 0) {
            NSRange secondRange = NSMakeRange(0, secondLength);
            [indexesToCache addIndexesInRange:secondRange];
        }

        [indexesToCache addIndex:self.posterImageFrameIndex];
    }

    return indexesToCache;
}


- (void)purgeFrameCacheIfNeeded
{
    if ([self.cachedFrameIndexes count] > self.frameCacheSizeCurrent) {
        NSMutableIndexSet *indexesToPurge = [self.cachedFrameIndexes mutableCopy];
        [indexesToPurge removeIndexes:[self frameIndexesToCache]];
        [indexesToPurge enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
                [self.cachedFrameIndexes removeIndex:i];
                [self.cachedFramesForIndexes removeObjectForKey:@(i)];
            }
        }];
    }
}



#pragma mark Image Decoding

- (CGContextRef)bitmapForDraw {
    CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceDeviceRGBRef) {
        return nil;
    }

    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1;

    void *data = NULL;
    size_t width = self.giftConfig.width;
    size_t height = self.giftConfig.height;
    size_t bitsPerComponent = CHAR_BIT;

    size_t bitsPerPixel = (bitsPerComponent * numberOfComponents);
    size_t bytesPerPixel = (bitsPerPixel / BYTE_SIZE);
    size_t bytesPerRow = (bytesPerPixel * width);

    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;

    CGImageAlphaInfo alphaInfo = kCGImageAlphaPremultipliedLast;
    bitmapInfo |= alphaInfo;
    CGContextRef bitmapContextRef = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, bitmapInfo);
    CGColorSpaceRelease(colorSpaceDeviceRGBRef);
    return bitmapContextRef;
}

- (UIImage *)predrawnImageWithContext:(CGContextRef)bitmapContextRef imagePath:(NSString *)imagePath maskPath:(NSString *)maskPath frame:(NSUInteger)index
{
    BQLAnimatedImageConfig *giftConfig = self.giftConfig;
    CGFloat width = giftConfig.width;
    CGFloat height = giftConfig.height;

    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImage *maskImage = [UIImage imageWithContentsOfFile:maskPath];

    if (image && maskImage) {
        CGRect rect = CGRectMake(0.0, 0.0, width, height);
        CGContextSaveGState(bitmapContextRef);
        CGContextClipToMask(bitmapContextRef, rect, maskImage.CGImage);
        CGContextDrawImage(bitmapContextRef, rect, image.CGImage);
        CGContextRestoreGState(bitmapContextRef);
    }

    for (NSString *subImageKey in giftConfig.subImageKeys) {
        UIImage *subImage = [giftConfig subImageWithKey:subImageKey];
        if (subImage) {
            BQLImageConfig *imageConfig = [giftConfig getSubImageConfigWithKey:subImageKey];
            BQLGiftFrameConfig frameConfig = [giftConfig getSubImageFrameConfigWithKey:subImageKey frame:index];
            if (frameConfig.alpha > 0 && frameConfig.scale > 0 && frameConfig.postion.size.width > 0 && frameConfig.postion.size.height > 0) {
                [self drawGiftResource:subImage config:imageConfig frameConfig:frameConfig contextRef:bitmapContextRef width:width height:height];
            }
        }
    }

    //---------------------特殊素材的绘制-------------------
    if (self.hostAvatar) {
        BQLGiftFrameConfig frameConfig = [giftConfig getHostAvatarConfigWithFrame:index];
        if (frameConfig.alpha > 0 && frameConfig.scale > 0 && frameConfig.postion.size.width > 0 && frameConfig.postion.size.height > 0) {
            [self drawGiftResource:self.hostAvatar config:self.giftConfig.hostAvatarConfig frameConfig:frameConfig contextRef:bitmapContextRef width:width height:height];
        }
    }
    if (self.senderAvatar) {
        BQLGiftFrameConfig frameConfig = [giftConfig getSenderAvatarConfigWithFrame:index];
        if (frameConfig.alpha > 0 && frameConfig.scale > 0 && frameConfig.postion.size.width > 0 && frameConfig.postion.size.height > 0) {
            [self drawGiftResource:self.senderAvatar config:self.giftConfig.senderAvatarConfig frameConfig:frameConfig contextRef:bitmapContextRef width:width height:height];
        }
    }
    if (self.hostNickname) {
        BQLGiftFrameConfig frameConfig = [giftConfig getHostNicknameConfigWithFrame:index];
        if (frameConfig.alpha > 0 && frameConfig.scale > 0 && frameConfig.postion.size.width > 0 && frameConfig.postion.size.height > 0) {
            [self drawGiftResText:self.hostNickname config:self.giftConfig.hostNickNameConfig frameConfig:frameConfig contextRef:bitmapContextRef width:width height:height];
        }
    }

    if (self.senderNickname) {
        BQLGiftFrameConfig frameConfig = [giftConfig getSenderNicknameConfigWithFrame:index];
        if (frameConfig.alpha > 0 && frameConfig.scale > 0 && frameConfig.postion.size.width > 0 && frameConfig.postion.size.height > 0) {
            [self drawGiftResText:self.senderNickname config:self.giftConfig.senderNickNameConfig frameConfig:frameConfig contextRef:bitmapContextRef width:width height:height];
        }
    }

    //----------------------------------------------
    CGImageRef predrawnImageRef = CGBitmapContextCreateImage(bitmapContextRef);

    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *predrawnImage = [UIImage imageWithCGImage:predrawnImageRef scale:scale  orientation:UIImageOrientationUp];
    CGImageRelease(predrawnImageRef);
    CGContextRelease(bitmapContextRef);

    return predrawnImage;
}

- (void)drawGiftResText:(NSString *)text  config:(BQLTextConfig *)config frameConfig: (BQLGiftFrameConfig)frameConfig contextRef:(CGContextRef)bitmapContextRef width: (CGFloat) widtdddh height: (CGFloat)height {
    CGContextSaveGState(bitmapContextRef);
    CGFloat rotate = -(frameConfig.rotate * M_PI / 180 );
    CGFloat scale = frameConfig.scale;
    CGFloat alpha = frameConfig.alpha;

    CGFloat x = frameConfig.postion.origin.x;
    CGFloat headerWidth = frameConfig.postion.size.width;
    CGFloat headerHeight = frameConfig.postion.size.height;
    CGFloat y = height - frameConfig.postion.origin.y - headerHeight;

    CGRect headerRect = CGRectMake(x, y, headerWidth, headerHeight);

    CGAffineTransform trans = CGAffineTransformTranslate(CGAffineTransformIdentity, CGRectGetMidX(headerRect), CGRectGetMidY(headerRect));
    CGAffineTransform afterRotate = CGAffineTransformRotate(trans, rotate);

    CGContextConcatCTM(bitmapContextRef, afterRotate);

    CGFloat scaleW = headerRect.size.width * scale;
    CGFloat scaleH = headerRect.size.height * scale;
    CGRect headerRectAfterScale = CGRectMake(-scaleW / 2, -scaleH / 2, scaleW, scaleH);

    CGFloat fontSize = 40;
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    BOOL shouldDec = YES;
    if (font.lineHeight < headerHeight) {
        shouldDec = NO;
    }
    while (true) {
        if (shouldDec) {
            fontSize -= 1;
            font = [UIFont boldSystemFontOfSize:fontSize];
            if (font.lineHeight <= headerHeight) {
                break;
            }
        }else {
            fontSize += 1;
            font = [UIFont boldSystemFontOfSize:fontSize];
            if (font.lineHeight >= headerHeight) {
                break;
            }
        }
    }

    CGContextSetAlpha(bitmapContextRef, alpha);

    // 3.创建绘制区域，可以对path进行个性化裁剪以改变显示区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, headerRectAfterScale);

    // 4.创建需要绘制的文字
    NSRange textRange = NSMakeRange(0, text.length);
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:text];

    [attributed addAttribute: NSFontAttributeName value: font range:textRange];


    if (config.color) {
        [attributed addAttribute: NSForegroundColorAttributeName value:config.color range:textRange];
    }

    //描边
    if (config.borderColor && config.borderWidth > 0) {
        [attributed addAttribute: NSStrokeColorAttributeName value: config.borderColor range: textRange];
        [attributed addAttribute: NSStrokeWidthAttributeName value: @(-3) range: textRange];
    }

    //阴影
    if (config.shadowColor && config.shadowBlur > 0) {
        CGContextSetShadowWithColor(bitmapContextRef, CGSizeMake(config.shadowX, -config.shadowY), config.shadowBlur, config.shadowColor.CGColor);
    }

    // 设置行距等样式
    CTTextAlignment alignment = kCTTextAlignmentCenter;
    if (config.textAlignment == NSTextAlignmentLeft) {
        alignment = kCTTextAlignmentLeft;
    } else if (config.textAlignment == NSTextAlignmentRight) {
        alignment = kCTTextAlignmentRight;
    }
    
    const CFIndex kNumberOfSettings = 1;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment}

    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);

    [attributed addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:textRange];

    CFRelease(theParagraphRef);

    // 5.根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);

    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, NULL);

    CTFrameDraw(ctFrame, bitmapContextRef);

    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(ctFrame);


    CGContextRestoreGState(bitmapContextRef);

}

- (void)drawGiftResource:(UIImage *)image config:(BQLImageConfig *)config frameConfig:(BQLGiftFrameConfig)frameConfig contextRef:(CGContextRef)bitmapContextRef width: (CGFloat) width height: (CGFloat)height {

    CGContextSaveGState(bitmapContextRef);
    CGFloat rotate = -(frameConfig.rotate * M_PI / 180);//android 顺时针
    CGFloat scale = frameConfig.scale;
    CGFloat alpha = frameConfig.alpha;

    CGFloat x = frameConfig.postion.origin.x;
    CGFloat headerWidth = frameConfig.postion.size.width;
    CGFloat headerHeight = frameConfig.postion.size.height;
    CGFloat y = height - frameConfig.postion.origin.y - headerHeight;


    CGRect headerRect = CGRectMake(x, y, headerWidth, headerHeight);

    CGAffineTransform trans = CGAffineTransformTranslate(CGAffineTransformIdentity, CGRectGetMidX(headerRect), CGRectGetMidY(headerRect));
    CGAffineTransform afterRotate = CGAffineTransformRotate(trans, rotate);

    CGContextConcatCTM(bitmapContextRef, afterRotate);

    CGFloat scaleW = headerRect.size.width * scale;
    CGFloat scaleH = headerRect.size.height * scale;
    CGRect headerRectAfterScale = CGRectMake(-scaleW / 2, -scaleH / 2, scaleW, scaleH);

    CGContextSetAlpha(bitmapContextRef, alpha);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRoundedRect(path, NULL, headerRectAfterScale, config.cornerRadius, config.cornerRadius);

    CGMutablePathRef path2 = NULL;

    //有描边
    if (config.borderWidth > 0 && config.borderColor) {
        CGRect headerRectAfterScale2 = CGRectMake(headerRectAfterScale.origin.x - config.borderWidth, headerRectAfterScale.origin.y - config.borderWidth, headerRectAfterScale.size.width + config.borderWidth * 2, headerRectAfterScale.size.height + config.borderWidth *2);
        path2 = CGPathCreateMutable();
        CGPathAddRoundedRect(path2, NULL, headerRectAfterScale2, config.cornerRadius + config.borderWidth, config.cornerRadius + config.borderWidth);
    }

    //阴影
    if (config.shadowColor && config.shadowBlur > 0) {
        CGContextSaveGState(bitmapContextRef);
        if (path2) {
            CGContextAddPath(bitmapContextRef, path2);
        } else {
            CGContextAddPath(bitmapContextRef, path);
        }

        CGContextSetShadowWithColor(bitmapContextRef, CGSizeMake(config.shadowX, config.shadowY), config.shadowBlur, config.shadowColor.CGColor);
        CGContextFillPath(bitmapContextRef);
        CGContextRestoreGState(bitmapContextRef);
    }

    //描边
    if (config.borderWidth > 0 && config.borderColor) {
        CGContextSaveGState(bitmapContextRef);
        CGContextAddPath(bitmapContextRef, path2);
        CGContextSetFillColorWithColor(bitmapContextRef, config.borderColor.CGColor);
        CGContextFillPath(bitmapContextRef);
        CGContextRestoreGState(bitmapContextRef);
    }

    //圆角
    CGContextSaveGState(bitmapContextRef);
    CGContextAddPath(bitmapContextRef, path);
    CGContextClip(bitmapContextRef);


    CGContextDrawImage(bitmapContextRef, headerRectAfterScale, image.CGImage);

    CGContextRestoreGState(bitmapContextRef);

    CGContextRestoreGState(bitmapContextRef);

}


#pragma mark - Gift Resource

- (void)loadGiftResource {
    if (_giftConfig && self.dataSource) {
        if (_giftConfig.needHostAvatar) {
            _hostAvatar = [self.dataSource getHostAvatar];
        }
        if (_giftConfig.needHostNickname) {
            _hostNickname = [self.dataSource getHostNickname];
        }
        if (_giftConfig.needSenderAvatar) {
            _senderAvatar = [self.dataSource getSenderAvatar];
        }
        if (_giftConfig.needSenderNickname) {
            _senderNickname = [self.dataSource getSenderNickname];
        }
    }
}


#pragma mark - Description

- (NSString *)description
{
    NSString *description = [super description];

    description = [description stringByAppendingFormat:@" frameCount=%lu", (unsigned long)self.frameCount];

    return description;
}


@end


#pragma mark - BMWeakProxy

@interface BMWeakProxy ()

@property (nonatomic, weak) id target;

@end



@implementation BMWeakProxy

#pragma mark Life Cycle

+ (instancetype)weakProxyForObject:(id)targetObject
{
    BMWeakProxy *weakProxy = [BMWeakProxy alloc];
    weakProxy.target = targetObject;
    return weakProxy;
}


#pragma mark Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector
{
    return _target;
}


#pragma mark - NSWeakProxy Method Overrides
#pragma mark Handling Unimplemented Methods

- (void)forwardInvocation:(NSInvocation *)invocation
{
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}


@end




