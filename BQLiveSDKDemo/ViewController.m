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
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.titles = [NSArray arrayWithObjects:@"直播",@"获取礼物列表",@"下载包", nil];

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
    return self.titles.count;
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
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LiveViewController *vc = [[LiveViewController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    }else if (indexPath.row == 1) {
        [[BQGiftManager defaultManager] getAllGiftsFromServer];
    }else if (indexPath.row == 2) {
        [[BQGiftManager defaultManager] downloadGifts];
    }

}

@end
