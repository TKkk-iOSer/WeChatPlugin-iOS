//
//  TKSettingViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKSettingViewController.h"
#import "TKEditViewController.h"
#import "WeChatRobot.h"
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
    [self addContactVerifySection];
    // [self addAutoReplySection];
    [self addGroupSettingSection];

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - 设置 TableView

- (void)addContactVerifySection {
    BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoVerifyEnable];
    BOOL welcomeEnable = [[TKRobotConfig sharedConfig] welcomeEnable];

    MMTableViewSectionInfo *verifySectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"过滤好友请求设置" Footer:nil];

    [verifySectionInfo addCell:[self createVerifySwitchCell]];
    if (autoVerifyEnable) {
        [verifySectionInfo addCell:[self createAutoVerifyCell]];
        // [verifySectionInfo addCell:[self createWelcomeSwitchCell]];
        if (welcomeEnable) {
            // [verifySectionInfo addCell:[self createWelcomeCell]];
        }
    }
    [self.tableViewInfo addSection:verifySectionInfo];
}

- (void)addAutoReplySection {
    BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];

    MMTableViewSectionInfo *autoReplySectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"自动回复设置" Footer:nil];

    [autoReplySectionInfo addCell:[self createAutoReplySwitchCell]];
    if (autoReplyEnable) {
        [autoReplySectionInfo addCell:[self createAutoReplyKeywordCell]];
        [autoReplySectionInfo addCell:[self createAutoReplyTextCell]];
    }
    [self.tableViewInfo addSection:autoReplySectionInfo];
}

- (void)addGroupSettingSection {
    BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];

    MMTableViewSectionInfo *groupSectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"群设置" Footer:nil];
    [groupSectionInfo addCell:[self createSetChatRoomDescCell]];
    [groupSectionInfo addCell:[self createGroupSendCell]];
    // [groupSectionInfo addCell:[self createWelcomeJoinChatRoomSwitchCell]];
    if (welcomeJoinChatRoomEnable) {
        [groupSectionInfo addCell:[self createWelcomeJoinChatRoomCell]];
    }
    [self.tableViewInfo addSection:groupSectionInfo];
}

#pragma mark - 添加好友设置
- (MMTableViewCellInfo *)createVerifySwitchCell {
    BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoVerifyEnable];

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingVerifySwitch:) target:self title:@"开启自动添加好友" on:autoVerifyEnable];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoVerifyCell {
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoVerifyKeyword];
    verifyText = verifyText.length == 0 ? @"请填写" : verifyText;

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingVerify) target:self title:@"请求验证关键词" rightValue:verifyText accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeSwitchCell {
    BOOL welcomeEnable = [[TKRobotConfig sharedConfig] welcomeEnable];

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingWelcomeSwitch:)target:self title:@"开启通过验证欢迎语" on:welcomeEnable];;

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeCell {
    NSString *welcomes = [[TKRobotConfig sharedConfig] welcomeText];
    welcomes = welcomes.length == 0 ? @"请填写" : welcomes;

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingWelcome) target:self title:@"验证通过欢迎语" rightValue:welcomes accessoryType:1];

    return cellInfo;
}

#pragma mark - 自动回复设置
- (MMTableViewCellInfo *)createAutoReplySwitchCell {
    BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingAutoReplySwitch:)target:self title:@"开启自动回复" on:autoReplyEnable];;

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyKeywordCell {
    NSString *autoReplyKeyword = [[TKRobotConfig sharedConfig] autoReplyKeyword];
    autoReplyKeyword = autoReplyKeyword.length == 0 ? @"请填写" : autoReplyKeyword;

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoReplyKeyword) target:self title:@"特定消息" rightValue:autoReplyKeyword accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyTextCell {
    NSString *autoReply = [[TKRobotConfig sharedConfig] autoReplyText];
    autoReply = autoReply.length == 0 ? @"请填写" : autoReply;

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoReply) target:self title:@"自动回复内容" rightValue:autoReply accessoryType:1];

    return cellInfo;
}

#pragma mark - 入群欢迎语

- (MMTableViewCellInfo *)createGroupSendCell {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingGroupSend) target:self title:@"群发设置" rightValue:nil accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createSetChatRoomDescCell {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingChatRoomDesc) target:self title:@"群公告设置" rightValue:nil accessoryType:1];

    return cellInfo;
}


- (MMTableViewCellInfo *)createWelcomeJoinChatRoomSwitchCell {
    BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingWelcomeJoinChatRoomSwitch:)target:self title:@"开启入群欢迎" on:welcomeJoinChatRoomEnable];;

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeJoinChatRoomCell {
    NSString *welcomeJoinChatRoomText = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomText];
    welcomeJoinChatRoomText = welcomeJoinChatRoomText.length == 0 ? @"请填写" : welcomeJoinChatRoomText;

    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingWelcomeJoinChatRoom) target:self title:@"入群欢迎语" rightValue:welcomeJoinChatRoomText accessoryType:1];

    return cellInfo;
}

#pragma mark - 设置cell相应的方法
- (void)settingVerifySwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoVerifyEnable:arg.on];
    [self reloadTableData];
}

- (void)settingWelcomeSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setWelcomeEnable:arg.on];
    [self reloadTableData];
}

- (void)settingAutoReplySwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoReplyEnable:arg.on];
    [self reloadTableData];
}

- (void)settingWelcomeJoinChatRoomSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setWelcomeJoinChatRoomEnable:arg.on];
    [self reloadTableData];
}

- (void)settingVerify {
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoVerifyKeyword];
    [self alertControllerWithTitle:@"自动添加好友设置"
                           message:verifyText
                       placeholder:@"请输入好友请求关键字"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setAutoVerifyKeyword:textField.text];
                                   [self reloadTableData];
                                   CMessageMgr *mgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CMessageMgr")];
                                   [mgr GetHelloUsers:@"fmessage" Limit:0 OnlyUnread:0];
                               }];
}

- (void)settingWelcome {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] welcomeText];
    editVC.title = @"请输入验证通过欢迎语";
    [editVC setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setWelcomeText:text];
        [self reloadTableData];
    }];
    [self.navigationController PushViewController:editVC animated:YES];

    return;
}

- (void)settingAutoReplyKeyword {
    NSString *autoReplyKeyword = [[TKRobotConfig sharedConfig] autoReplyKeyword];
    [self alertControllerWithTitle:@"特点消息设置"
                           message:autoReplyKeyword
                       placeholder:@"请输入特定消息"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setAutoReplyKeyword:textField.text];
                                   [self reloadTableData];
                               }];
}

- (void)settingAutoReply {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] autoReplyText];
    [editVC setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoReplyText:text];
        [self reloadTableData];
    }];
    editVC.title = @"请输入自动回复的内容";
    [self.navigationController PushViewController:editVC animated:YES];

    return;
}

- (void)settingGroupSend {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] groupSendText];
    // editVC.title = @"是我";
    [editVC setEndEditing:^(NSString *text) {
        // return;
        // CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        //
        // CMessageMgr *messageMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CMessageMgr")];
        // NSArray *contactArray = [contactMgr getContactList:1 contactType:0];
        //
        // NSLog(@"contact = %@\n,m_uiFriendScene = %d\n m_isPlugin = %d\n chatroom = %d",contact,contact.m_uiFriendScene,[contact m_isPlugin],[contact isChatroom]);
        // [messageMgr sendMsg:text toContactUsrName:contact.m_nsUsrName];
        // [self reloadTableData];
    }];
    [self.navigationController PushViewController:editVC animated:YES];
}

- (void)settingChatRoomDesc {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] groupSendText];
    editVC.title = @"群公告设置";
    [editVC setEndEditing:^(NSString *text) {
        // return;
        ContactsDataLogic *dataLogic = [[objc_getClass("ContactsDataLogic") alloc] initWithScene:5 delegate:nil sort:0];
        [dataLogic reloadContacts];
        NSString *chatRoomKey = [[dataLogic getKeysArray] firstObject];

        NSArray *chatRoomArray = [dataLogic getContactsArrayWith:chatRoomKey];
        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];

        CContact *selfContact = [contactMgr getSelfContact];
        NSLog(@"self = %p %@",selfContact,selfContact);
        [chatRoomArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
            if([contact isChatroom] && [selfContact.m_nsUsrName isEqualToString:contact.m_nsOwner]) {
                CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CGroupMgr")];
                [groupMgr SetChatRoomDesc:contact.m_nsUsrName Desc:text Flag:1];
            }
            NSLog(@"%@",contact.m_nsUsrName);
        }];
        [self reloadTableData];
    }];
    [self.navigationController PushViewController:editVC animated:YES];
}

- (void)settingWelcomeJoinChatRoom {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomText];
    editVC.title = @"请输入入群欢迎语";
    [editVC setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setWelcomeJoinChatRoomText:text];
        [self reloadTableData];
    }];
    [self.navigationController PushViewController:editVC animated:YES];

    return;
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
