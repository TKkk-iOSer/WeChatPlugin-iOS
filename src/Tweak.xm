#import "WeChatRobot.h"
#import "TKRobotConfig.h"
#import "TKSettingViewController.h"
#import "EmoticonGameCheat.h"

%hook CMessageMgr

- (void)AddEmoticonMsg:(NSString *)msg MsgWrap:(CMessageWrap *)msgWrap {
    if ([[TKRobotConfig sharedConfig] preventGameCheatEnable]) { // 是否开启游戏作弊
        if ([msgWrap m_uiMessageType] == 47 && ([msgWrap m_uiGameType] == 2|| [msgWrap m_uiGameType] == 1)) {
            [EmoticonGameCheat showEoticonCheat:[msgWrap m_uiGameType] callback:^(NSInteger random){
                [msgWrap setM_nsEmoticonMD5:[objc_getClass("GameController") getMD5ByGameContent:random]];
                [msgWrap setM_uiGameContent:random];
                %orig(msg, msgWrap);
            }];
            return;
        }
    }

    %orig(msg, msgWrap);
}

- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(NSDictionary *)info Event:(unsigned int)arg3 {
    %orig;
    CMessageWrap *wrap = [info objectForKey:@"18"];

    if (arg1 == 227) {
        NSDate *now = [NSDate date];
        NSTimeInterval nowSecond = now.timeIntervalSince1970;
        if (nowSecond - wrap.m_uiCreateTime > 60) {      // 若是1分钟前的消息，则不进行处理。
            return;
        }
        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        CContact *contact = [contactMgr getContactByName:wrap.m_nsFromUsr];
        if(wrap.m_uiMessageType == 1) {                                         // 收到文本消息
            if (contact.m_uiFriendScene == 0 && ![contact isChatroom]) {
                //        该消息为公众号
                return;
            }
            if (![contact isChatroom]) {                                        // 是否为群聊
                [self autoReplyWithMessageWrap:wrap];                           // 自动回复个人消息
            } else {
                [self removeMemberWithMessageWrap:wrap];                        // 自动踢人
                [self autoReplyChatRoomWithMessageWrap:wrap];                   // 自动回复群消息
            }
        } else if(wrap.m_uiMessageType == 10000) {                              // 收到群通知，eg:群邀请了好友；删除了好友。
            CContact *selfContact = [contactMgr getSelfContact];
            if([selfContact.m_nsUsrName isEqualToString:contact.m_nsOwner]) {   // 只有自己创建的群，才发送群欢迎语
                [self welcomeJoinChatRoomWithMessageWrap:wrap];
            }
        }
    } else if (arg1 == 332) {                                                          // 收到添加好友消息
        [self addAutoVerifyWithMessageInfo:info];
    }
}

- (id)GetHelloUsers:(id)arg1 Limit:(unsigned int)arg2 OnlyUnread:(_Bool)arg3 {
    id userNameArray = %orig;
    if ([arg1 isEqualToString:@"fmessage"] && arg2 == 0 && arg3 == 0) {
        [self addAutoVerifyWithArray:userNameArray arrayType:TKArrayTpyeMsgUserName];
    }

    return userNameArray;
}

- (void)onRevokeMsg:(CMessageWrap *)arg1 {
    if ([[TKRobotConfig sharedConfig] preventRevokeEnable]) {
        NSString *msgContent = arg1.m_nsContent;

    	NSString *(^parseParam)(NSString *, NSString *,NSString *) = ^NSString *(NSString *content, NSString *paramBegin,NSString *paramEnd) {
    		NSUInteger startIndex = [content rangeOfString:paramBegin].location + paramBegin.length;
    		NSUInteger endIndex = [content rangeOfString:paramEnd].location;
    		NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
    		return [content substringWithRange:range];
    	};

        NSString *session = parseParam(msgContent, @"<session>", @"</session>");
        NSString *newmsgid = parseParam(msgContent, @"<newmsgid>", @"</newmsgid>");
        NSString *fromUsrName = parseParam(msgContent, @"<![CDATA[", @"撤回了一条消息");
        CMessageWrap *revokemsg = [self GetMsg:session n64SvrID:[newmsgid integerValue]];

        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        CContact *selfContact = [contactMgr getSelfContact];
        NSString *newMsgContent = @"";


        if ([revokemsg.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
               if (revokemsg.m_uiMessageType == 1) {       // 判断是否为文本消息
                   newMsgContent = [NSString stringWithFormat:@"拦截到你撤回了一条消息：\n %@",revokemsg.m_nsContent];
               } else {
                   newMsgContent = @"拦截到你撤回一条消息";
               }
        } else {
                if (revokemsg.m_uiMessageType == 1) {
                       newMsgContent = [NSString stringWithFormat:@"拦截到一条 %@撤回消息：\n %@",fromUsrName, revokemsg.m_nsContent];
                   } else {
                        newMsgContent = [NSString stringWithFormat:@"拦截到一条 %@撤回消息",fromUsrName];
               }
        }

        CMessageWrap *newWrap = ({
                CMessageWrap *msg = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];
                [msg setM_nsFromUsr:revokemsg.m_nsFromUsr];
                [msg setM_nsToUsr:revokemsg.m_nsToUsr];
                [msg setM_uiStatus:0x4];
                [msg setM_nsContent:newMsgContent];
                [msg setM_uiCreateTime:[arg1 m_uiCreateTime]];

                msg;
            });

    	[self AddLocalMsg:session MsgWrap:newWrap fixTime:0x1 NewMsgArriveNotify:0x0];
        return;
    }
    %orig;
}

%new
- (void)autoReplyWithMessageWrap:(CMessageWrap *)wrap {
    BOOL autoReplyEnable = [[TKRobotConfig sharedConfig] autoReplyEnable];
    NSString *autoReplyContent = [[TKRobotConfig sharedConfig] autoReplyText];
    if (!autoReplyEnable || autoReplyContent == nil || [autoReplyContent isEqualToString:@""]) {                                                     // 是否开启自动回复
        return;
    }

    NSString * content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
    NSString *needAutoReplyMsg = [[TKRobotConfig sharedConfig] autoReplyKeyword];
    NSArray * keyWordArray = [needAutoReplyMsg componentsSeparatedByString:@"||"];
    [keyWordArray enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([keyword isEqualToString:@"*"] || [content isEqualToString:keyword]) {
            [self sendMsg:autoReplyContent toContactUsrName:wrap.m_nsFromUsr];
        }
    }];
}

%new
- (void)removeMemberWithMessageWrap:(CMessageWrap *)wrap {
    BOOL chatRoomSensitiveEnable = [[TKRobotConfig sharedConfig] chatRoomSensitiveEnable];
    if (!chatRoomSensitiveEnable) {
        return;
    }

    CGroupMgr *groupMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CGroupMgr")];
    NSString *content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
    NSMutableArray *array = [[TKRobotConfig sharedConfig] chatRoomSensitiveArray];
    [array enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
        if([content isEqualToString:text]) {
            [groupMgr DeleteGroupMember:wrap.m_nsFromUsr withMemberList:@[wrap.m_nsRealChatUsr] scene:3074516140857229312];
    }
    }];
}

%new
- (void)autoReplyChatRoomWithMessageWrap:(CMessageWrap *)wrap {
    BOOL autoReplyChatRoomEnable = [[TKRobotConfig sharedConfig] autoReplyChatRoomEnable];
    NSString *autoReplyChatRoomContent = [[TKRobotConfig sharedConfig] autoReplyChatRoomText];
    if (!autoReplyChatRoomEnable || autoReplyChatRoomContent == nil || [autoReplyChatRoomContent isEqualToString:@""]) {                                                     // 是否开启自动回复
        return;
    }

    NSString * content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
    NSString *needAutoReplyChatRoomMsg = [[TKRobotConfig sharedConfig] autoReplyChatRoomKeyword];
    NSArray * keyWordArray = [needAutoReplyChatRoomMsg componentsSeparatedByString:@"||"];
    [keyWordArray enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([keyword isEqualToString:@"*"] || [content isEqualToString:keyword]) {
            [self sendMsg:autoReplyChatRoomContent toContactUsrName:wrap.m_nsFromUsr];
        }
    }];
}

%new
- (void)welcomeJoinChatRoomWithMessageWrap:(CMessageWrap *)wrap {
    BOOL welcomeJoinChatRoomEnable = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomEnable];
    if (!welcomeJoinChatRoomEnable) return;                                     // 是否开启入群欢迎语




    NSString * content = MSHookIvar<id>(wrap, "m_nsLastDisplayContent");
    NSRange rangeFrom = [content rangeOfString:@"邀请\""];
    NSRange rangeTo = [content rangeOfString:@"\"加入了群聊"];
    NSRange nameRange;
    if (rangeFrom.length > 0 && rangeTo.length > 0) {                           // 通过别人邀请进群
        NSInteger nameLocation = rangeFrom.location + rangeFrom.length;
        nameRange = NSMakeRange(nameLocation, rangeTo.location - nameLocation);
    } else {
        NSRange range = [content rangeOfString:@"\"通过扫描\""];
        if (range.length > 0) {                                                 // 通过二维码扫描进群
            nameRange = NSMakeRange(2, range.location - 2);
        } else {
            return;
        }
    }

    NSString *welcomeJoinChatRoomText = [[TKRobotConfig sharedConfig] welcomeJoinChatRoomText];
    [self sendMsg:welcomeJoinChatRoomText toContactUsrName:wrap.m_nsFromUsr];
}

%new
- (void)addAutoVerifyWithMessageInfo:(NSDictionary *)info {
    BOOL autoVerifyEnable = [[TKRobotConfig sharedConfig] autoVerifyEnable];

    if (!autoVerifyEnable)
        return;

    NSString *keyStr = [info objectForKey:@"5"];
    if ([keyStr isEqualToString:@"fmessage"]) {
        NSArray *wrapArray = [info objectForKey:@"27"];
        [self addAutoVerifyWithArray:wrapArray arrayType:TKArrayTpyeMsgWrap];
    }
}

%new        // 自动通过好友请求
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

            // 发送欢迎语
            BOOL autoWelcomeEnable = [[TKRobotConfig sharedConfig] autoWelcomeEnable];
            NSString *autoWelcomeText = [[TKRobotConfig sharedConfig] autoWelcomeText];
            if (autoWelcomeEnable && autoWelcomeText != nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self sendMsg:autoWelcomeText toContactUsrName:contact.m_nsUsrName];
                });
            }
        }
    }
}

%new        // 发送消息
- (void)sendMsg:(NSString *)msg toContactUsrName:(NSString *)userName {
    CMessageWrap *wrap = [[%c(CMessageWrap) alloc] initWithMsgType:1];
    id usrName = [%c(SettingUtil) getLocalUsrName:0];
    [wrap setM_nsFromUsr:usrName];
    [wrap setM_nsContent:msg];
    [wrap setM_nsToUsr:userName];
    MMNewSessionMgr *sessionMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(MMNewSessionMgr)];
    [wrap setM_uiCreateTime:[sessionMgr GenSendMsgTime]];
    [wrap setM_uiStatus:YES];

    CMessageMgr *chatMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CMessageMgr)];
    [chatMgr AddMsg:userName MsgWrap:wrap];
}
%end

%hook NewSettingViewController
- (void)reloadTableData {
	%orig;
	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	MMTableViewCellInfo *settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"微信小助手" accessoryType:1];
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

// %hook MicroMessengerAppDelegate
// - (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
//     BOOL finish = %orig;
//
//     static dispatch_once_t onceToken;
//     dispatch_once(&onceToken, ^{
//         Method originalBundleIdentifierMethod = class_getInstanceMethod([NSBundle class], @selector(bundleIdentifier));
//         Method swizzledBundleIdentifierMethod = class_getInstanceMethod([NSBundle class], @selector(tk_bundleIdentifier));
//         if(originalBundleIdentifierMethod && swizzledBundleIdentifierMethod) {
//             method_exchangeImplementations(originalBundleIdentifierMethod, swizzledBundleIdentifierMethod);
//         }
//
//         Method originalInfoDictionaryMethod = class_getInstanceMethod([NSBundle class], @selector(infoDictionary));
//         Method swizzledInfoDictionaryMethod = class_getInstanceMethod([NSBundle class], @selector(tk_infoDictionary));
//         if(originalInfoDictionaryMethod && swizzledInfoDictionaryMethod) {
//             method_exchangeImplementations(originalInfoDictionaryMethod, swizzledInfoDictionaryMethod);
//         }
//
//     });
//     return finish;
// }
// %end

%hook WCDeviceStepObject
-(NSInteger)m7StepCount {
    NSInteger stepCount = %orig;
    NSInteger newStepCount = [[TKRobotConfig sharedConfig] deviceStep];
    BOOL changeStepEnable = [[TKRobotConfig sharedConfig] changeStepEnable];

    return changeStepEnable ? newStepCount : stepCount;
}

-(NSInteger)hkStepCount {
    NSInteger stepCount = %orig;
    NSInteger newStepCount = [[TKRobotConfig sharedConfig] deviceStep];
    BOOL changeStepEnable = [[TKRobotConfig sharedConfig] changeStepEnable];

    return changeStepEnable ? newStepCount : stepCount;
}

%end
