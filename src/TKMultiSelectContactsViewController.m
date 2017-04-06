//
//  TKMultiSelectContactsViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/4/5.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKMultiSelectContactsViewController.h"

@interface TKMultiSelectContactsViewController ()

@property (nonatomic, strong) ContactSelectView *selectView;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation TKMultiSelectContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self initNav];
    [self initView];

}

- (void)initNav {
    self.navigationItem.leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"返回" target:self action:@selector(onBack) style:3];
    self.navigationItem.rightBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"全选" target:self action:@selector(onAllSelect) style:4];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)initView {
    self.selectView = ({
        CGRect frame =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45);
        ContactSelectView *selectV = [[objc_getClass("ContactSelectView") alloc] initWithFrame:frame];
        [selectV setM_uiGroupScene:5];
        [selectV setM_bMultiSelect:1];
        [selectV setM_dicExistContact:nil];
        [selectV setM_dicMultiSelect:nil];
        [selectV initData:5];
        [selectV initView];
        [selectV makeGroupCell:nil head:nil title:@"哈哈"];

        selectV;
    });

    self.nextBtn = ({
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45);
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setBackgroundColor: [UIColor colorWithRed: 0x10/255.0 green:0xc4/255.0 blue:0xd1/255.0 alpha:1]];
        [btn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];

        btn;
    });

    [self.view addSubview:self.selectView];
    [self.view addSubview:self.nextBtn];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onAllSelect {
    ContactsDataLogic *dataLogic = [[objc_getClass("ContactsDataLogic") alloc] initWithScene:5 delegate:nil sort:0];
    [dataLogic reloadContacts];
    NSString *chatRoomKey = [[dataLogic getKeysArray] firstObject];
    NSArray *chatRoomArray = [dataLogic getContactsArrayWith:chatRoomKey];
    [chatRoomArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.selectView addSelect:contact];
    }];

    MMTableView *tableView = [self.selectView valueForKey:@"m_tableView"];
    [tableView reloadData];
}

- (void)onNext {
    if (self.selectView.m_dicMultiSelect.allKeys.count == 0) {
        return;
    }

    NSArray *chatRoomContacts =  self.selectView.m_dicMultiSelect.allValues;
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.text = [[TKRobotConfig sharedConfig] allChatRoomDescText];
    editVC.title = @"请输入群公告";
    [editVC setEndEditing:^(NSString *text) {
        [[TKRobotConfig sharedConfig] setAllChatRoomDescText:text];
        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        CContact *selfContact = [contactMgr getSelfContact];
        [chatRoomContacts enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
            if([contact isChatroom] && [selfContact.m_nsUsrName isEqualToString:contact.m_nsOwner]) {
                CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CGroupMgr")];
                [groupMgr SetChatRoomDesc:contact.m_nsUsrName Desc:text Flag:1];
            }
            NSLog(@"%@",contact.m_nsUsrName);
        }];
    }];
    [self.navigationController PushViewController:editVC animated:YES];
}


@end
