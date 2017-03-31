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
    MMTableViewSectionInfo *baseSectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];

    [baseSectionInfo addCell:[self createAutoVerifyCell]];
    [baseSectionInfo addCell:[self createWelcomesCell]];
    [self.tableViewInfo addSection:baseSectionInfo];

    MMTableViewSectionInfo *autoReplySectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"特定消息自动回复设置" Footer:nil];

    [autoReplySectionInfo addCell:[self createNeedReplyMsgCell]];
    [autoReplySectionInfo addCell:[self createAutoReplyContentCell]];
    [autoReplySectionInfo addCell:[self createGroupSendCell]];
    [self.tableViewInfo addSection:autoReplySectionInfo];

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

- (MMTableViewCellInfo *)createNeedReplyMsgCell {
    MMTableViewCellInfo *cellInfo;
    NSString *needAutoReplyMsg = [[TKRobotConfig sharedConfig] needAutoReplyMsg];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingNeedReplyMsg) target:self title:@"特定消息" rightValue:needAutoReplyMsg accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyContentCell {
    MMTableViewCellInfo *cellInfo;
    NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyContent];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoReplyContent) target:self title:@"自动回复内容" rightValue:autoReplyContent accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createGroupSendCell {
    MMTableViewCellInfo *cellInfo;
    NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyContent];
    cellInfo =  [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingGroupSend) target:self title:@"群发设置" rightValue:autoReplyContent accessoryType:1];

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
        CMessageMgr *mgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CMessageMgr")];
        [mgr GetHelloUsers:@"fmessage" Limit:0 OnlyUnread:0];
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

- (void)settingNeedReplyMsg {
    NSString *needAutoReplyMsg = [[TKRobotConfig sharedConfig] needAutoReplyMsg];
    [self alertControllerWithTitle:@"特点消息设置"
                           message:needAutoReplyMsg
                       placeholder:@"请输入特定消息"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setNeedAutoReplyMsg:textField.text];
                                   [self reloadTableData];
                               }];
}

- (void)settingAutoReplyContent {
    NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyContent];
    [self alertControllerWithTitle:@"自动回复设置"
                           message:autoReplyContent
                       placeholder:@"请输入自动回复内容"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setAutoReplyContent:textField.text];
                                   [self reloadTableData];
                               }];
}

- (void)settingGroupSend {
    NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyContent];
    [self alertControllerWithTitle:@"群发内容"
                           message:autoReplyContent
                       placeholder:@"请输入自动回复内容"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setAutoReplyContent:textField.text];
                                   [self reloadTableData];
                                   CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
                                   CMessageMgr *messageMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CMessageMgr")];
                                   NSArray *contactArray = [contactMgr getContactList:1 contactType:0];
                                   [contactArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
                                       if(contact.m_uiFriendScene && ![contact m_isPlugin]) {
                                           [messageMgr sendMsg:textField.text toContactUsrName:contact.m_nsUsrName];
                                       }
                                   }];
                               }];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:nil
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
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
