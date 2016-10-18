//
//  HomeViewController.m
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "LiveViewController.h"
#import "SM_Masonry.h"
#import "BQLAnimatedImage.h"
#import "BQLAnimatedImageView.h"
#import "BQLAnimatedImageConfig.h"
#import <BQLiveSDK/BQLiveSDK.h>

@interface LiveViewController ()<BMLAnimatedImageViewDelegate, BMLAnimatedImageDataSource>
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *sendGiftButton;
@property(strong, nonatomic) BQLAnimatedImageView *imageView;

@end

@implementation LiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [self.camera.view mas_makeConstraints:^(SM_MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
        
        [self.switchButton mas_makeConstraints:^(SM_MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right).offset(-15);
            make.top.equalTo(self.view.mas_top).offset(15);
            make.width.equalTo(@49);
            make.height.equalTo(@44);
        }];
    }
    
    _sendGiftButton = [UIButton new];
    [_sendGiftButton setTintColor:[UIColor whiteColor]];
    _sendGiftButton.backgroundColor = [UIColor redColor];
    [_sendGiftButton setTitle:@"送礼物" forState:UIControlStateNormal];
    [_sendGiftButton addTarget:self action:@selector(sendGift) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _sendGiftButton];
    [_sendGiftButton mas_makeConstraints:^(SM_MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@64);
        make.height.equalTo(@44);
    }];
    
    
    _backButton = [UIButton new];
    _backButton.backgroundColor = [UIColor clearColor];
    [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    _backButton.contentMode = UIViewContentModeCenter;
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    [_backButton mas_makeConstraints:^(SM_MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).offset(15);
        make.width.equalTo(@60);
        make.height.equalTo(@44);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // start the camera
    [self.camera start];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendGift {
    _sendGiftButton.hidden = YES;
    [self.view bringSubviewToFront:_backButton];
    
    
    //第一步：资源文件路径准备
    
    //第二步：配置文件读取
    BQLAnimatedImageConfig *config = [[BQLAnimatedImageConfig alloc] initWithDictionyPath:self.giftPath];
    
    //第三步：实例化 BQLAnimatedImage 对象
    BQLAnimatedImage *animatedImage = [BQLAnimatedImage animatedImageWithConfig:config dataSource:self];
    animatedImage.loopCount = 1;
    
    //第四步：实例化控件并播放
    BQLAnimatedImageView *imageView = [[BQLAnimatedImageView alloc] init];
    imageView.delegate = self;
    imageView.alpha = 1;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    if (_gift) {
        if (_gift.fullScreen) {
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView mas_makeConstraints:^(SM_MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuide);
                make.bottom.equalTo(self.mas_bottomLayoutGuide);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
            }];
            imageView.animatedImage = animatedImage;
        }else{
            imageView.contentMode = UIViewContentModeCenter;
            [imageView mas_makeConstraints:^(SM_MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
                make.centerY.equalTo(self.view.mas_centerY);
            }];
            imageView.animatedImage = animatedImage;
        }
        
        //第五步：记录发送礼物的log
        [BQLiveManager logSendGiftWithUserId:@"user_id" userName:@"user_name" giftId:_gift.guid
                                    giftName:_gift.name giftPrice:_gift.price toHostId:@"host_id" hostName:@"host_name"];
        
        //记录礼物展示的log
        [BQLiveManager logViewGiftWithUserId:@"user_id" userName:@"user_name" giftId:_gift.guid
                                    giftName:_gift.name giftPrice:_gift.price toHostId:@"host_id" hostName:@"host_name"];
    }
    
}

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

/* other lifecycle methods */

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - BMLAnimatedImageViewDelegate

- (void)giftResourceReady:(BQLAnimatedImageView *)aImageView {
    
}

- (void)giftAnimationDidPlay:(BQLAnimatedImageView *)aImageView {
    
}

- (void)giftAnimationDidFinish:(BQLAnimatedImageView *)aImageView {
    [UIView animateWithDuration:0.4 animations:^{
        self.imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        self.sendGiftButton.hidden = NO;
    }];
}

#pragma mark - BMLAnimatedImageDataSource

- (UIImage *)getHostAvatar {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hostAvatar" ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)getHostNickname {
    return @"nicholaspeterwilson";
}

- (UIImage *)getSenderAvatar {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"senderAvatar" ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)getSenderNickname {
    return @"andressa_teodoro_";
}

@end
