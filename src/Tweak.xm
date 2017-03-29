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

- (void)OnSayHelloDataVerifyContactOK:(CPushContact *)contact{
    %log;
    %orig;
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

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *welcomesText = [[TKRobotConfig sharedConfig] welcomesText];
                [self sendMsg:welcomesText toContact:contact];
            });

        }
    }
}

%new
- (void)sendMsg:(NSString *)msg toContact:(CPushContact *)contact {
    CMessageWrap *wrap = [[%c(CMessageWrap) alloc] initWithMsgType:265395718666059777];
    id usrName = [%c(SettingUtil) getLocalUsrName:0];
    [wrap setM_nsFromUsr:usrName];
    [wrap setM_nsContent:msg];
    [wrap setM_nsToUsr:contact.m_nsUsrName];
    MMNewSessionMgr * sessionMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(MMNewSessionMgr)];
    [wrap setM_uiCreateTime:[sessionMgr GenSendMsgTime]];
    [wrap setM_uiStatus:YES];

    CMessageMgr *chatMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CMessageMgr)];
    [chatMgr AddMsg: contact.m_nsUsrName MsgWrap:wrap];
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
