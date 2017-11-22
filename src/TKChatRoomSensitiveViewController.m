//
//  TKChatRoomSensitiveViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/4/7.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKChatRoomSensitiveViewController.h"
#import "WeChatRobot.h"

@interface TKChatRoomSensitiveViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;
@property (nonatomic, strong) NSMutableArray *chatRoomSensitiveArray;

@end

@implementation TKChatRoomSensitiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 增加对iPhone X的屏幕适配
        CGRect winSize = [UIScreen mainScreen].bounds;
        if (winSize.size.height == 812) {
            winSize.size.height -= 88;
            winSize.origin.y = 88;
        }
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:winSize style:UITableViewStyleGrouped];
        _tableViewInfo.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self reloadTableData];
    [self initTitle];
    MMTableView *tableView = [self.tableViewInfo getTableView];

    [self.view addSubview:tableView];
}

- (void)initData {
    self.chatRoomSensitiveArray = ({
        NSMutableArray *array = [[TKRobotConfig sharedConfig] chatRoomSensitiveArray];
        NSMutableArray *copyArray;
        if (array == nil) {
            copyArray = [NSMutableArray array];
        } else {
            copyArray = [NSMutableArray arrayWithArray:array];
        }

        copyArray;
    });
}

- (void)initTitle {
    self.title = @"敏感词名单";
    self.navigationItem.leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"返回" target:self action:@selector(onBack) style:3];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    [self addHeaderSection];
    if (self.chatRoomSensitiveArray.count > 0) {
        [self addSensitiveTextSection];
    }

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

- (void)addHeaderSection {
    MMTableViewSectionInfo *headerSectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:nil Footer:nil];
    [headerSectionInfo addCell:[self createSensitiveSwitchCell]];
    [headerSectionInfo addCell:[self createNewSensitiveCell]];
    [self.tableViewInfo addSection:headerSectionInfo];
}

- (void)addSensitiveTextSection {
    MMTableViewSectionInfo *sensitiveTextSection = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"敏感词" Footer:nil];

    [self.chatRoomSensitiveArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sensitiveTextSection addCell:[self createSensitiveCellWithIndex:idx andText:obj]];
    }];

    [self.tableViewInfo addSection:sensitiveTextSection];
}

- (MMTableViewCellInfo *)createSensitiveSwitchCell {
    BOOL chatRoomSensitiveEnable = [[TKRobotConfig sharedConfig] chatRoomSensitiveEnable];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingSensitiveSwitch:)target:self title:@"开启敏感词检测" on:chatRoomSensitiveEnable];

    return cellInfo;
}

- (MMTableViewCellInfo *)createNewSensitiveCell {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(addSensitiveAction) target:self title:@"新增敏感词" accessoryType:1];

    return cellInfo;
}

- (MMTableViewCellInfo *)createSensitiveCellWithIndex:(int)index andText:(NSString *)text {
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(editSensitiveText:) target:self title:text accessoryType:1];
    cellInfo.userInfo = @{@"index" : @(index),@"text":text};
    cellInfo.editStyle = UITableViewCellEditingStyleDelete;

    return cellInfo;
}

- (void)settingSensitiveSwitch:(UISwitch *)arg {
    [[TKRobotConfig sharedConfig] setChatRoomSensitiveEnable:arg.on];
    [self reloadTableData];
}

- (void)addSensitiveAction {
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.title = @"新增敏感词";
    editVC.placeholder = @"当管理的群中有用户发了跟敏感词一致的内容，\n则自动将其提出该群";
    [editVC setEndEditing:^(NSString *text) {
        __block BOOL isRepetition = NO;
        [self.chatRoomSensitiveArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:text]) {
                isRepetition = YES;
                *stop= YES;
            }
        }];

        if (isRepetition) {
            [TKToast toast:@"敏感词重复"];
            return;
        }

        [self.chatRoomSensitiveArray addObject:text];
        [[TKRobotConfig sharedConfig] setChatRoomSensitiveArray:self.chatRoomSensitiveArray];
        [self reloadTableData];
    }];

    [self.navigationController PushViewController:editVC animated:YES];
}

- (void)editSensitiveText:(MMTableViewCellInfo *)agr {
    NSInteger index = [agr.userInfo[@"index"] integerValue];
    TKEditViewController *editVC = [[TKEditViewController alloc] init];
    editVC.title = @"编辑敏感词";
    editVC.placeholder = @"当管理的群中有用户发了跟敏感词一致的内容，\n则自动将其提出该群";
    editVC.text = agr.userInfo[@"text"];
    [editVC setEndEditing:^(NSString *text) {
        __block BOOL isRepetition = NO;
        [self.chatRoomSensitiveArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:text]) {
                isRepetition = YES;
                *stop= YES;
            }
        }];

        if (isRepetition) {
            [TKToast toast:@"敏感词重复"];
            return;
        }
        [self.chatRoomSensitiveArray replaceObjectAtIndex:index withObject:text];
        [[TKRobotConfig sharedConfig] setChatRoomSensitiveArray:self.chatRoomSensitiveArray];
        [self reloadTableData];
    }];

    [self.navigationController PushViewController:editVC animated:YES];
}

- (void)commitEditingForRowAtIndexPath:(NSIndexPath *)arg1 Cell:(MMTableViewCellInfo *)arg2 {
    [self.chatRoomSensitiveArray removeObjectAtIndex:arg1.row];
    [[TKRobotConfig sharedConfig] setChatRoomSensitiveArray:self.chatRoomSensitiveArray];
    MMTableViewSectionInfo *sensitiveTextSection = [self.tableViewInfo getSectionAt:1];
    [sensitiveTextSection removeCellAt:arg1.row];
    [self reloadTableData];
}

@end
