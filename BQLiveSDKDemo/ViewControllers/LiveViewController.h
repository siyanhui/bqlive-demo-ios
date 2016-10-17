//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import <BQLiveSDK/BQLiveSDK.h>

@interface LiveViewController : UIViewController

@property (nonatomic, strong) NSString *giftPath;

@property (nonatomic, strong) BQGift *gift;

@end
