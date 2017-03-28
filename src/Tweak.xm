#import "TKSettingViewController.h"
#import "WeChatRobot.h"
#import "TKRobotConfig.h"

%hook SayHelloViewController

- (void)OnSayHelloDataChange {

    [self addAutoVerifyAction];
    %log;
    %orig;
}

- (void)viewDidAppear:(BOOL)animated {
    %log;
    %orig;
    [self addAutoVerifyAction];
}

%new
- (void)addAutoVerifyAction {
    NSString *verifyText = [[TKRobotConfig sharedConfig] autoContactVerifyText];

    SayHelloDataLogic *helloDataLogic = [self valueForKey:@"m_DataLogic"];
    NSMutableArray *m_arrHellos = [helloDataLogic valueForKey:@"m_arrHellos"];
    for (int idx = 0;idx < m_arrHellos.count;idx++) {
        CPushContact *contact = [helloDataLogic getContactForIndex:idx];

        if (![contact isMyContact] && [contact.m_nsDes isEqualToString:verifyText]) {
            CContactVerifyLogic *verifyLogic = [[%c(CContactVerifyLogic) alloc] init];
            CVerifyContactWrap *wrap = [[%c(CVerifyContactWrap) alloc] init];
            [wrap setM_nsUsrName:contact.m_nsEncodeUserName];
            [wrap setM_uiScene:contact.m_uiFriendScene];
            [wrap setM_nsTicket:contact.m_nsTicket];
            [wrap setM_nsChatRoomUserName:contact.m_nsChatRoomUserName];
            wrap.m_oVerifyContact = contact;

            AutoSetRemarkMgr *mgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(AutoSetRemarkMgr)];
            id attr = [mgr GetStrangerAttribute:contact AttributeName:1001];

            if([attr boolValue]) {
                [wrap setM_uiWCFlag:(wrap.m_uiWCFlag | 1)];
            }
            UITableView *tableView = [self valueForKey:@"m_tableView"];
            [verifyLogic startWithVerifyContactWrap:[NSArray arrayWithObject:wrap] opCode:3 parentView:tableView fromChatRoom:NO];
        }
    }
}
%end

%hook NewSettingViewController

- (void)reloadTableData {
	%orig;

	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	MMTableViewCellInfo *settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"TK小助手" accessoryType:1];
	[sectionInfo addCell:settingCell];
	[tableViewInfo insertSection:sectionInfo At:0];
	MMTableView *tableView = [tableViewInfo getTableView];
	[tableView reloadData];
}

%new
- (void)setting {
	TKSettingViewController *settingViewController = [[TKSettingViewController alloc] init];
	[self.navigationController PushViewController:settingViewController animated:YES];
}

%end
