//
//  TKMultiSelectContactsViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/4/5.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKMultiSelectContactsViewController.h"

@interface TKMultiSelectContactsViewController ()

@property (nonatomic, strong) MMLoadingView *loadingView;
@property (nonatomic, strong) ContactSelectView *selectView;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation TKMultiSelectContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initNav];
    [self initView];
    [self setup];
}

- (void)setup {
    self.view.backgroundColor = [UIColor whiteColor];

    [self.loadingView startLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self filterOwnChatRoom];
        [self.selectView setHidden:NO];
    });
}

- (void)initNav {
    self.navigationItem.leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"返回" target:self action:@selector(onBack) style:3];
    self.navigationItem.rightBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"全选" target:self action:@selector(onAllSelect) style:4];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)initView {
    self.loadingView = ({
        MMLoadingView *loadingView = [[objc_getClass("MMLoadingView") alloc] init];
        [loadingView.m_label setText:@"加载中…"];
        [loadingView setM_bIgnoringInteractionEventsWhenLoading:YES];
        [loadingView setFitFrame:1];

        loadingView;
    });

    self.selectView = ({
        CGRect frame =  CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45);
        ContactSelectView *selectV = [[objc_getClass("ContactSelectView") alloc] initWithFrame:frame];
        [selectV setM_uiGroupScene:5];
        [selectV setM_bMultiSelect:1];
        [selectV setM_dicExistContact:nil];
        [selectV setM_dicMultiSelect:nil];
        [selectV initData:5];
        [selectV initView];
        [selectV setHidden:YES];

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
    [self.view addSubview:self.loadingView];
}

- (void)filterOwnChatRoom {
    ContactsDataLogic *contactDataLogic = [self.selectView valueForKey:@"m_contactsDataLogic"];
    NSString *chatRoomKey = [[contactDataLogic getKeysArray] firstObject];
    NSArray *chatRoomArray = [contactDataLogic getContactsArrayWith:chatRoomKey];

    CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
    CContact *selfContact = [contactMgr getSelfContact];
    NSMutableArray *owmChatRoom = [NSMutableArray array];
    [chatRoomArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
        if([contact isChatroom] && [selfContact.m_nsUsrName isEqualToString:contact.m_nsOwner]) {
            [owmChatRoom addObject:contact];
        }
    }];
    NSMutableDictionary *dicAllContacts = [contactDataLogic valueForKey:@"m_dicAllContacts"];
    dicAllContacts[chatRoomKey] = owmChatRoom;

    MMTableView *tableView = [self.selectView valueForKey:@"m_tableView"];
    [tableView reloadData];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onAllSelect {
    ContactsDataLogic *contactDataLogic = [self.selectView valueForKey:@"m_contactsDataLogic"];
    NSString *chatRoomKey = [[contactDataLogic getKeysArray] firstObject];
    NSArray *chatRoomArray = [contactDataLogic getContactsArrayWith:chatRoomKey];
    [chatRoomArray enumerateObjectsUsingBlock:^(CContact *contact, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.selectView addSelect:contact];
    }];

    MMTableView *tableView = [self.selectView valueForKey:@"m_tableView"];
    [tableView reloadData];
}

- (void)onNext {
    if (self.selectView.m_dicMultiSelect.allKeys.count == 0) {
        [TKToast toast:@"至少选择一个群聊"];
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
        }];
    }];
    [self.navigationController PushViewController:editVC animated:YES];
}

@end
