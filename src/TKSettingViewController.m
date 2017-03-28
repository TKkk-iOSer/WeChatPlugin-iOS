//
//  TKSettingViewController.m
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKSettingViewController.h"
#import "WeChatRobot.h"
#import <objc/runtime.h>
#import "TKRobotConfig.h"

@interface TKSettingViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation TKSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reloadTableData];
    [self initTitle];
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)initTitle {
    self.title = @"TK小助手";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    [self addsettingSection];

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

- (void)addsettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];

    [sectionInfo addCell:[self createAutoVerifyCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createAutoVerifyCell {
    MMTableViewCellInfo *cellInfo;
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoContactVerifyText];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingVerify) target:self title:@"关键词" rightValue:verifyText accessoryType:1];

    return cellInfo;
}

- (void)settingVerify {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自动添加好友设置" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alert.textFields.firstObject;
            [[TKRobotConfig sharedConfig] setAutoContactVerifyText:textField.text];
            [self reloadTableData];
        }]];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入自动添加验证码";
        }];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}


@end
