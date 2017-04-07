#import "TKSettingViewController.h"
#import "WeChatRobot.h"
#import "TKRobotConfig.h"

%hook CMessageMgr
- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(NSDictionary *)info Event:(unsigned int)arg3 {
    %orig;
    if (arg1 == 227) {  // 收到消息
        CMessageWrap *wrap = [info objectForKey:@"18"];
        NSString * content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
        if(wrap.m_uiMessageType == 1) {    // 收到文本消息
            [self deleteContact:wrap];
            BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];
            if (!autoReplyEnable)       // 是否开启自动回复
                return;

            NSString *needAutoReplyMsg = [[TKRobotConfig sharedConfig] autoReplyKeyword];
            if([content isEqualToString:needAutoReplyMsg]) {
                NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyText];
                [self sendMsg:autoReplyContent toContactUsrName:wrap.m_nsFromUsr];
            }
        } else if(wrap.m_uiMessageType == 10000) {          // 收到群通知，eg:群邀请了好友；删除了好友。
            BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];
            if (!welcomeJoinChatRoomEnable)     // 是否开启入群欢迎语
                return;

            // NSMutableString * mutableContent =  [[%c(NSMutableString) alloc] initWithString:content];
            NSRange rangeFrom = [content rangeOfString:@"邀请\""];
            NSRange rangeTo = [content rangeOfString:@"\"加入了群聊"];
            NSRange nameRange;
            if (rangeFrom.length > 0 && rangeTo.length > 0) {     // 通过别人邀请进群
                NSInteger nameLocation = rangeFrom.location + rangeFrom.length;
                nameRange = NSMakeRange(nameLocation, rangeTo.location - nameLocation);
            } else {
                NSRange range = [content rangeOfString:@"\"通过扫描\""];
                if (range.length > 0) {     // 通过二维码扫描进群
                    nameRange = NSMakeRange(2, range.location - 2);
                } else {
                    return;
                }
            }
            // NSString *newMemberName = [mutableContent substringWithRange:nameRange];
            NSString *welcomeJoinChatRoomText = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomText];
            [self sendMsg:welcomeJoinChatRoomText toContactUsrName:wrap.m_nsFromUsr];
        }
    } else if (arg1 == 332) {   // 收到添加好友消息
        BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoVerifyEnable];
        if (!autoVerifyEnable)
            return;

        NSString *keyStr = [info objectForKey:@"5"];
        if ([keyStr isEqualToString:@"fmessage"]) {
            NSArray *wrapArray = [info objectForKey:@"27"];
            [self addAutoVerifyWithArray:wrapArray arrayType:TKArrayTpyeMsgWrap];
        }
    }
}

- (id)GetHelloUsers:(id)arg1 Limit:(unsigned int)arg2 OnlyUnread:(_Bool)arg3 {
    %log;
    id userNameArray = %orig;
    if ([arg1 isEqualToString:@"fmessage"] && arg2 == 0 && arg3 == 0) {
        [self addAutoVerifyWithArray:userNameArray arrayType:TKArrayTpyeMsgUserName];
    }

    return userNameArray;
}

%new
- (void)addAutoVerifyWithArray:(NSArray *)ary arrayType:(TKArrayTpye)type {
    NSMutableArray *arrHellos = [NSMutableArray array];
    [ary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (type == TKArrayTpyeMsgWrap) {
            CPushContact *contact = [%c(SayHelloDataLogic) getContactFrom:obj];
            [arrHellos addObject:contact];
        } else if (type == TKArrayTpyeMsgUserName) {
            FriendAsistSessionMgr *asistSessionMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(FriendAsistSessionMgr)];
            CMessageWrap *wrap = [asistSessionMgr GetLastMessage:@"fmessage" HelloUser:obj OnlyTo:NO];
            CPushContact *contact = [%c(SayHelloDataLogic) getContactFrom:wrap];
            [arrHellos addObject:contact];
        }
    }];

    NSString *autoVerifyKeyword = [[TKRobotConfig sharedConfig] autoVerifyKeyword];

    for (int idx = 0;idx < arrHellos.count;idx++) {
        CPushContact *contact = arrHellos[idx];
        if (![contact isMyContact] && [contact.m_nsDes isEqualToString:autoVerifyKeyword]) {
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
            [verifyLogic startWithVerifyContactWrap:[NSArray arrayWithObject:wrap] opCode:3 parentView:[UIView new] fromChatRoom:NO];

            BOOL welcomeEnable = [[TKRobotConfig sharedConfig] welcomeEnable];
            if (!welcomeEnable) {   // 是否发送添加好友欢迎语
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *welcomesText = [[TKRobotConfig sharedConfig] welcomeText];
                [self sendMsg:welcomesText toContactUsrName:contact.m_nsUsrName];
            });
        }
    }
}

%new
- (void)sendMsg:(NSString *)msg toContactUsrName:(NSString *)userName {
    CMessageWrap *wrap = [[%c(CMessageWrap) alloc] initWithMsgType:265395718666059777];
    id usrName = [%c(SettingUtil) getLocalUsrName:0];
    [wrap setM_nsFromUsr:usrName];
    [wrap setM_nsContent:msg];
    [wrap setM_nsToUsr:userName];
    MMNewSessionMgr * sessionMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(MMNewSessionMgr)];
    [wrap setM_uiCreateTime:[sessionMgr GenSendMsgTime]];
    [wrap setM_uiStatus:YES];

    CMessageMgr *chatMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CMessageMgr)];
    [chatMgr AddMsg:userName MsgWrap:wrap];
}

%new
- (void)deleteContact:(CMessageWrap *)wrap {
    CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CGroupMgr")];
    NSString * content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
    if(wrap.m_uiMessageType == 1) {    // 收到文本消息
        NSMutableString *mutStr = [NSMutableString stringWithFormat:@""];

        unsigned int outCount = 0;
        Ivar * ivars = class_copyIvarList(%c(CMessageWrap), &outCount);
        for (unsigned int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            const char * name = ivar_getName(ivar);
            const char * type = ivar_getTypeEncoding(ivar);

            id str = [wrap valueForKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
            [mutStr appendString:[NSString stringWithFormat:@"类型为 %s 的 %s %@\n",type, name,str]];

        }
        free(ivars);

        NSLog(@":%@",mutStr);


        if([content isEqualToString:@"傻"]) {
            [groupMgr DeleteGroupMember:wrap.m_nsFromUsr withMemberList:@[wrap.m_nsRealChatUsr] scene:3074516140857229312];
        }
    }
}

%end

%hook NewSettingViewController
- (void)reloadTableData {
	%orig;
	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	MMTableViewCellInfo *settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"微信机器人" accessoryType:1];
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
