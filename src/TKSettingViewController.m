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

#pragma mark - 设置 TableView

- (void)addsettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];

    [sectionInfo addCell:[self createAutoVerifyCell]];
    [sectionInfo addCell:[self createWelcomesCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createAutoVerifyCell {
    MMTableViewCellInfo *cellInfo;
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoContactVerifyText];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingVerify) target:self title:@"自动加好友关键词" rightValue:verifyText accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomesCell {
    MMTableViewCellInfo *cellInfo;
    NSString *welcomes = [[TKRobotConfig sharedConfig] welcomesText];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingWelcome) target:self title:@"添加好友欢迎语" rightValue:welcomes accessoryType:1];

    return cellInfo;
}

#pragma mark - 设置cell相应的方法

- (void)settingVerify {

    NSString *verifyText = [[TKRobotConfig sharedConfig] autoContactVerifyText];
    [self alertControllerWithTitle:@"自动添加好友设置"
                           message:verifyText
                       placeholder:@"请输入自动添加验证码"
                               blk:^(UITextField *textField) {
        [[TKRobotConfig sharedConfig] setAutoContactVerifyText:textField.text];
        [self reloadTableData];
    }];
}

- (void)settingWelcome {
    NSString *welcomes = [[TKRobotConfig sharedConfig] welcomesText];
    [self alertControllerWithTitle:@"欢迎语设置"
                           message:welcomes
                       placeholder:@"请输入欢迎语"
                               blk:^(UITextField *textField) {
        [[TKRobotConfig sharedConfig] setWelcomesText:textField.text];
        [self reloadTableData];
    }];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (blk) {
                blk(alert.textFields.firstObject);
            }
        }]];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeholder;
            textField.text = message;
        }];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
