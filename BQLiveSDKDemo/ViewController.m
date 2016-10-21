//
//  ViewController.m
//  BMLiveSDKDemo
//
//  Created by Tender on 16/9/2.
//  Copyright © 2016年 Tender. All rights reserved.
//

#import "ViewController.h"
#import "SM_Masonry.h"
#import "LiveViewController.h"
#import <BQLiveSDK/BQLiveSDK.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray<BQGift *> *remoteGifts;
@property (nonatomic, strong) NSArray<BQGift *> *localGifts;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.titles = [NSArray arrayWithObjects:@"直播(内置)",@"第一步：获取礼物列表",@"第二步：下载包", nil];
    [BQGiftManager defaultManager];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)loadView {
    [super loadView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(SM_MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.indicatorView.frame = CGRectMake(0, 0, 120, 120);
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(SM_MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@(120));
        make.height.equalTo(@120);
    }];
    self.indicatorView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDataFromLocal];
}

- (void)loadDataFromLocal {
    __weak ViewController *weakSelf = self;
    [[BQGiftManager defaultManager] getAllGiftsFromLocal:^(NSArray<BQGift *> * _Nullable gifts) {
        __strong ViewController *strong = weakSelf;
        if (strong) {
            strong.localGifts = gifts;
            [strong.tableView reloadData];
        }
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"本地数据库打开失败 %@", error);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count + self.localGifts.count + self.remoteGifts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"UITableViewCell.Default";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.textColor = [UIColor blackColor];
    if (indexPath.row < self.titles.count) {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = self.titles[indexPath.row];
        cell.imageView.image = nil;
    } else {
        BQGift *gift = nil;
        NSUInteger index = indexPath.row - self.titles.count;
        if (index < self.localGifts.count) {
            gift = self.localGifts[index];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(已下载，侧滑编辑)", gift.name];
        }else {
            index = index - self.localGifts.count;
            if (index < self.remoteGifts.count) {
                gift = self.remoteGifts[index];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.text = [NSString stringWithFormat:@"%@(未下载)", gift.name];
            }
        }

        if (gift) {
            NSURL *thunbUrl = [NSURL URLWithString:[gift.thumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if (thunbUrl) {
                cell.imageView.image = [UIImage imageNamed:@"icon_placeholder.png"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:thunbUrl];
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.imageView setImage:image];
                        [cell setNeedsDisplay];
                    });
                });
            }
        }

    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.titles.count) {
        return NO;
    }
    NSUInteger index = indexPath.row - self.titles.count;
    if (index < self.localGifts.count) {
        return YES;
    }
    return NO;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.titles.count) {
        return nil;
    }
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row >= self.titles.count) {
            NSUInteger index = indexPath.row - self.titles.count;
            if (index < self.localGifts.count) {
                BQGift *gift = self.localGifts[index];
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.localGifts];
                [array removeObjectAtIndex:index];
                self.localGifts = array.copy;
                [self.tableView reloadData];
                [[BQGiftManager defaultManager] deleteGift:gift finish:^(NSError * _Nullable error) {
                }];
            }
        }
    }];
    return @[action];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LiveViewController *vc = [[LiveViewController alloc] init];
        vc.giftPath = [[NSBundle mainBundle] resourcePath];
        [self.navigationController pushViewController:vc animated:true];
    }else if (indexPath.row == 1) {
        __weak ViewController *weakSelf = self;
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
        [[BQGiftManager defaultManager] getAllGiftsFromServer:^(NSArray<BQGift *> * _Nullable gifts) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                [strong.indicatorView stopAnimating];
                strong.indicatorView.hidden = YES;
                if (strong.localGifts.count > 0) {
                    NSMutableArray *remotes = [[NSMutableArray alloc] init];
                    for (BQGift *gift in gifts) {
                        BOOL hasDownloaded = NO;
                        for (BQGift *lGift in strong.localGifts) {
                            if ([lGift.guid isEqualToString:gift.guid]) {
                                hasDownloaded = YES;
                                break;
                            }
                        }
                        if (!hasDownloaded) {
                            [remotes addObject:gift];
                        }
                    }
                    strong.remoteGifts = remotes;
                } else {
                    strong.remoteGifts = gifts;
                }
                [strong.tableView reloadData];
            }
        } fail:^(NSError * _Nonnull error) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                NSLog(@"get gifts list fail");
            }
        }];
    }else if (indexPath.row == 2) {
        __weak ViewController *weakSelf = self;
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
        [[BQGiftManager defaultManager] downloadGifts:self.remoteGifts finish:^(NSArray<BQGift *> * _Nullable failGifts) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                [strong.indicatorView stopAnimating];
                strong.indicatorView.hidden = YES;
                strong.remoteGifts = [NSArray array];
                NSLog(@"download gifts %lu , %lu fail", (unsigned long)strong.remoteGifts.count, (unsigned long)failGifts.count);
                [strong loadDataFromLocal];
            }
        }];
    }else {
        NSUInteger index = indexPath.row - self.titles.count;
        if (index < self.localGifts.count) {
            BQGift *gift = self.localGifts[index];
            LiveViewController *vc = [[LiveViewController alloc] init];
            vc.giftPath = [[BQGiftManager defaultManager] pathForGift:gift];
            vc.gift = gift;
            [self.navigationController pushViewController:vc animated:true];
        }
    }
    
}

@end
