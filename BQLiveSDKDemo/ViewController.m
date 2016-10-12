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
@property (nonatomic, strong) NSArray<BQGift *> *gifts;
@property (nonatomic, strong) NSArray<BQGift *> *remoteGifts;

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
            strong.gifts = gifts;
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
    return self.titles.count + self.gifts.count;
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
    } else {
        NSUInteger index = indexPath.row - self.titles.count;
        if (index < self.gifts.count) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = [NSString stringWithFormat:@"%@(已下载，侧滑编辑)", self.gifts[index].name];
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.titles.count) {
        return false;
    }
    return true;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.titles.count) {
        return nil;
    }
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row >= self.titles.count) {
            NSUInteger index = indexPath.row - self.titles.count;
            if (index < self.gifts.count) {
                BQGift *gift = self.gifts[index];
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.gifts];
                [array removeObjectAtIndex:index];
                self.gifts = array.copy;
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
        [[BQGiftManager defaultManager] getAllGiftsFromServer:^(NSArray<BQGift *> * _Nullable gifts) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                strong.remoteGifts = gifts;
            }
        } fail:^(NSError * _Nonnull error) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                NSLog(@"get gifts list fail");
            }
        }];
    }else if (indexPath.row == 2) {
        __weak ViewController *weakSelf = self;
        [[BQGiftManager defaultManager] downloadGifts:self.remoteGifts finish:^(NSArray<BQGift *> * _Nullable failGifts) {
            __strong ViewController *strong = weakSelf;
            if (strong) {
                NSLog(@"download gifts %u , %u fail", strong.remoteGifts.count, failGifts.count);
                [strong loadDataFromLocal];
            }
        }];
    }else {
        NSUInteger index = indexPath.row - self.titles.count;
        if (index < self.gifts.count) {
            BQGift *gift = self.gifts[index];
            LiveViewController *vc = [[LiveViewController alloc] init];
            vc.giftPath = [[BQGiftManager defaultManager] pathForGift:gift];
            [self.navigationController pushViewController:vc animated:true];
        }
    }

}

@end
