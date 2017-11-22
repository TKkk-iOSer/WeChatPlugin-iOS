//
//  TKSettingViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKSettingViewController.h"
#import "WeChatRobot.h"
#import "TKMultiSelectContactsViewController.h"
#import "TKChatRoomSensitiveViewController.h"
#import "TKToast.h"

@interface TKSettingViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation TKSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 增加对iPhone X的屏幕适配
        CGRect winSize = [UIScreen mainScreen].bounds;
        if (winSize.size.height == 812) { // iPhone X 高为812
            winSize.size.height -= 88;
            winSize.origin.y = 88;
        }
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:winSize style:UITableViewStyleGrouped];
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
    self.title = @"微信小助手";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    [self addNiubilitySection];
    [self addContactVerifySection];
    [self addAutoReplySection];
    [self addGroupSettingSection];

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - 设置 TableView
- (void)addNiubilitySection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"装逼必备" Footer:nil];
    [sectionInfo addCell:[self createStepSwitchCell]];

    BOOL changeStepEnable = [[TKRobotConfig sharedConfig] changeStepEnable];
    if (changeStepEnable) {
        [sectionInfo addCell:[self createStepCountCell]];
    }
    [sectionInfo addCell:[self createRevokeSwitchCell]];
    [sectionInfo addCell:[self createGameCheatSwitchCell]];

    [self.tableViewInfo addSection:sectionInfo];
}

- (void)addContactVerifySection {
    MMTableViewSectionInfo *verifySectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"过滤好友请求设置" Footer:nil];
    [verifySectionInfo addCell:[self createVerifySwitchCell]];

    BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoVerifyEnable];
    if (autoVerifyEnable) {
        [verifySectionInfo addCell:[self createAutoVerifyCell]];

        BOOL autoWelcomeEnable = [[TKRobotConfig sharedConfig] autoWelcomeEnable];
        [verifySectionInfo addCell:[self createWelcomeSwitchCell]];
        if (autoWelcomeEnable) {
            [verifySectionInfo addCell:[self createWelcomeCell]];
        }
    }
    [self.tableViewInfo addSection:verifySectionInfo];
}

- (void)addAutoReplySection {
    MMTableViewSectionInfo *autoReplySectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"自动回复设置" Footer:nil];
    [autoReplySectionInfo addCell:[self createAutoReplySwitchCell]];

    BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];
    if (autoReplyEnable) {
        [autoReplySectionInfo addCell:[self createAutoReplyKeywordCell]];
        [autoReplySectionInfo addCell:[self createAutoReplyTextCell]];
    }
    [self.tableViewInfo addSection:autoReplySectionInfo];
}

- (void)addGroupSettingSection {
    MMTableViewSectionInfo *groupSectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"群设置" Footer:nil];
    [groupSectionInfo addCell:[self createSetChatRoomDescCell]];
    [groupSectionInfo addCell:[self createAutoDeleteMemberCell]];
    [groupSectionInfo addCell:[self createWelcomeJoinChatRoomSwitchCell]];

    BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];
    if (welcomeJoinChatRoomEnable) {
        [groupSectionInfo addCell:[self createWelcomeJoinChatRoomCell]];
    }
    [groupSectionInfo addCell:[self createAutoReplyChatRoomSwitchCell]];

    BOOL autoReplyChatRoomEnable = [[TKRobotConfig sharedConfig] autoReplyChatRoomEnable];
    if (autoReplyChatRoomEnable) {
        [groupSectionInfo addCell:[self createAutoReplyChatRoomKeywordCell]];
        [groupSectionInfo addCell:[self createAutoReplyChatRoomTextCell]];
    }

    [self.tableViewInfo addSection:groupSectionInfo];
}

#pragma mark - 装逼必备
- (MMTableViewCellInfo *)createStepSwitchCell {
    BOOL changeStepEnable = [[TKRobotConfig sharedConfig] changeStepEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingStepSwitch:) target:self title:@"是否修改微信步数" on:changeStepEnable];

    return cellInfo;
}

- (MMTableViewCellInfo *)createStepCountCell {
    NSInteger deviceStep = [[TKRobotConfig sharedConfig] deviceStep];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingStepCount) target:self title:@"微信运动步数" rightValue:[NSString stringWithFormat:@"%ld", (long)deviceStep] accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createRevokeSwitchCell {
    BOOL preventRevokeEnable = [[TKRobotConfig sharedConfig] preventRevokeEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingRevokeSwitch:) target:self title:@"拦截撤回消息" on:preventRevokeEnable];

    return cellInfo;
}

- (MMTableViewCellInfo *)createGameCheatSwitchCell {
    BOOL preventGameCheatEnable = [[TKRobotConfig sharedConfig] preventGameCheatEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingGameCheatSwitch:) target:self title:@"开启游戏作弊" on:preventGameCheatEnable];

    return cellInfo;
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
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingVerify) target:self title:@"自动通过关键词" rightValue:verifyText accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeSwitchCell {
    BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoWelcomeEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingWelcomeSwitch:) target:self title:@"开启欢迎语" on:autoVerifyEnable];

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeCell {
    NSString *welcomeText = [[TKRobotConfig sharedConfig] autoWelcomeText];
    welcomeText = welcomeText.length == 0 ? @"请填写" : welcomeText;
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingWelcome) target:self title:@"欢迎语内容" rightValue:welcomeText accessoryType:1];

    return cellInfo;
}

#pragma mark - 自动回复设置
- (MMTableViewCellInfo *)createAutoReplySwitchCell {
    BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingAutoReplySwitch:)target:self title:@"开启个人消息自动回复" on:autoReplyEnable];;

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

#pragma mark - 群相关设置

- (MMTableViewCellInfo *)createSetChatRoomDescCell {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingChatRoomDesc) target:self title:@"群公告设置" rightValue:nil accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoDeleteMemberCell {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoDeleteMember) target:self title:@"自动踢人设置" rightValue:nil accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeJoinChatRoomSwitchCell {
    BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingWelcomeJoinChatRoomSwitch:)target:self title:@"开启入群欢迎语" on:welcomeJoinChatRoomEnable];;

    return cellInfo;
}

- (MMTableViewCellInfo *)createWelcomeJoinChatRoomCell {
    NSString *welcomeJoinChatRoomText = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomText];
    welcomeJoinChatRoomText = welcomeJoinChatRoomText.length == 0 ? @"请填写" : welcomeJoinChatRoomText;
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingWelcomeJoinChatRoom) target:self title:@"入群欢迎语" rightValue:welcomeJoinChatRoomText accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyChatRoomSwitchCell {
    BOOL autoReplyChatRoomEnable = [[TKRobotConfig sharedConfig] autoReplyChatRoomEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingAutoReplyChatRoomSwitch:)target:self title:@"开启群消息自动回复" on:autoReplyChatRoomEnable];;

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyChatRoomKeywordCell {
    NSString *autoReplyChatRoomKeyword = [[TKRobotConfig sharedConfig] autoReplyChatRoomKeyword];
    autoReplyChatRoomKeyword = autoReplyChatRoomKeyword.length == 0 ? @"请填写" : autoReplyChatRoomKeyword;
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoReplyChatRoomKeyword) target:self title:@"特定消息" rightValue:autoReplyChatRoomKeyword accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createAutoReplyChatRoomTextCell {
    NSString *autoReplyChatRoomText = [[TKRobotConfig sharedConfig] autoReplyChatRoomText];
    autoReplyChatRoomText = autoReplyChatRoomText.length == 0 ? @"请填写" : autoReplyChatRoomText;
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(settingAutoReplyChatRoom) target:self title:@"自动回复内容" rightValue:autoReplyChatRoomText accessoryType:1];

    return cellInfo;
}

#pragma mark - 设置cell相应的方法
- (void)settingStepSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setChangeStepEnable:arg.on];
    [self reloadTableData];
}

- (void)settingStepCount {
    NSInteger deviceStep = [[TKRobotConfig sharedConfig] deviceStep];
    [self alertControllerWithTitle:@"微信运动设置"
                           message:@"步数需比之前设置的步数大才能生效，最大值为98800"
                           content:[NSString stringWithFormat:@"%ld", (long)deviceStep]
                       placeholder:@"请输入步数"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setDeviceStep:textField.text.integerValue];
                                   [self reloadTableData];
                               }];
}

- (void)settingRevokeSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setPreventRevokeEnable:arg.on];
    [self reloadTableData];
}

- (void)settingGameCheatSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setPreventGameCheatEnable:arg.on];
    [self reloadTableData];
}

- (void)settingVerifySwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoVerifyEnable:arg.on];
    [self reloadTableData];
}

- (void)settingVerify {
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoVerifyKeyword];
    [self alertControllerWithTitle:@"自动通过设置"
                           message:@"新的好友发送的验证内容与该关键字一致时，则自动通过"
                           content:verifyText
                       placeholder:@"请输入好友请求关键字"
                               blk:^(UITextField *textField) {
                                   [[TKRobotConfig sharedConfig] setAutoVerifyKeyword:textField.text];
                                   [self reloadTableData];
                                   CMessageMgr *mgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CMessageMgr")];
                                   [mgr GetHelloUsers:@"fmessage" Limit:0 OnlyUnread:0];
                               }];
}


- (void)settingWelcomeSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoWelcomeEnable:arg.on];
    [self reloadTableData];
}

- (void)settingWelcome {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] autoWelcomeText];
    [editVC setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoWelcomeText:text];
        [self reloadTableData];
    }];
    editVC.title = @"请输入欢迎语内容";
    editVC.placeholder = @"当自动通过好友请求时，则自动发送欢迎语；\n若手动通过，则不发送";
    [self.navigationController PushViewController:editVC animated:YES];
}

- (void)settingAutoReplySwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoReplyEnable:arg.on];
    [self reloadTableData];
}

- (void)settingAutoReplyKeyword {
    NSString *autoReplyKeyword = [[TKRobotConfig sharedConfig] autoReplyKeyword];
    TKEditViewController *editViewController = [[TKEditViewController alloc] init];
    [editViewController setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoReplyKeyword:text];
        [self reloadTableData];
    }];
    editViewController.title = @"个人消息自动回复";
    editViewController.text = autoReplyKeyword;
    editViewController.placeholder = @"请输入关键字（ ‘*’ 为任何消息都回复，\n‘||’ 为匹配多个关键字）";
    [self.navigationController PushViewController:editViewController animated:YES];
}

- (void)settingAutoReply {
    TKEditViewController *editViewController = [[TKEditViewController alloc] init];
    editViewController.text = [[TKRobotConfig sharedConfig] autoReplyText];
    [editViewController setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoReplyText:text];
        [self reloadTableData];
    }];
    editViewController.title = @"请输入自动回复的内容";
    [self.navigationController PushViewController:editViewController animated:YES];
}

- (void)settingAutoReplyChatRoomSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setAutoReplyChatRoomEnable:arg.on];
    [self reloadTableData];
}

- (void)settingAutoReplyChatRoomKeyword {
    NSString *autoReplyChatRoomKeyword = [[TKRobotConfig sharedConfig] autoReplyChatRoomKeyword];
    TKEditViewController *editViewController = [[TKEditViewController alloc] init];
    [editViewController setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoReplyChatRoomKeyword:text];
        [self reloadTableData];
    }];
    editViewController.title = @"群消息自动回复";
    editViewController.text = autoReplyChatRoomKeyword;
    editViewController.placeholder = @"请输入关键字（ ‘*’ 为任何消息都回复，\n‘||’ 为匹配多个关键字）";
    [self.navigationController PushViewController:editViewController animated:YES];
}

- (void)settingAutoReplyChatRoom {
    TKEditViewController *editViewController = [[TKEditViewController alloc] init];
    editViewController.text = [[TKRobotConfig sharedConfig] autoReplyChatRoomText];
    [editViewController setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAutoReplyChatRoomText:text];
        [self reloadTableData];
    }];
    editViewController.title = @"请输入自动回复的内容";
    [self.navigationController PushViewController:editViewController animated:YES];
}

- (void)settingWelcomeJoinChatRoomSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setWelcomeJoinChatRoomEnable:arg.on];
    [self reloadTableData];
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
}

- (void)settingChatRoomDesc {
    TKMultiSelectContactsViewController *selectVC = [[TKMultiSelectContactsViewController alloc] init];
    selectVC.title = @"我创建的群聊";
    [self.navigationController PushViewController:selectVC animated:YES];
}

- (void)settingAutoDeleteMember {
    TKChatRoomSensitiveViewController *vc = [[TKChatRoomSensitiveViewController alloc] init];
    vc.title = @"设置敏感词";
    [self.navigationController PushViewController:vc animated:YES];
}

// - (void)settingAutoCreateGroup {
//     [self alertControllerWithTitle:@"选择联系人"
//                            message:nil
//                        placeholder:@"请输入联系人过滤条件"
//                                blk:^(UITextField *textField) {
//                                    CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
//
//                                    NSArray *contactArray = [contactMgr getContactList:1 contactType:0];
//                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((m_nsNickName CONTAINS %@) OR (m_nsRemark CONTAINS %@)) AND isChatroom = 0 AND m_isPlugin == 0 AND m_uiFriendScene != 0", textField.text, textField.text];
//                                    NSArray *filteredArray = [contactArray filteredArrayUsingPredicate:predicate];
//                                    NSMutableArray *memberList = [[NSMutableArray alloc] init];
//                                    [filteredArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
//                                          GroupMember *member = [[objc_getClass("GroupMember") alloc] init];
//                                          member.m_nsMemberName = contact.m_nsUsrName;
//                                          member.m_uiMemberStatus = 0;
//                                          member.m_nsNickName = contact.m_nsNickName;
//                                          [memberList addObject:member];
//                                     }];
//
//                                     [self alertControllerWithTitle:@"群名称"
//                                                            message:nil
//                                                        placeholder:@"请输入群名称"
//                                                                blk:^(UITextField *textField) {
//                                         CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CGroupMgr")];
//                                         [groupMgr CreateGroup:textField.text withMemberList:memberList];
//
//                                         [TKToast toast:@"建群成功，请在会话列表中查看..."];
//                                     }];
//                                }];
// }

- (void)alertControllerWithTitle:(NSString *)title content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:nil content:content placeholder:placeholder blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:message content:content placeholder:placeholder keyboardType:UIKeyboardTypeDefault blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType blk:(void (^)(UITextField *))blk  {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
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
            textField.text = content;
            textField.keyboardType = keyboardType;
        }];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
