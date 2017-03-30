//
//  WeChatRobot.h
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

@class CPushContact, SayHelloDataLogic;

#pragma mark - Manager

@interface MMNewSessionMgr : NSObject
- (unsigned int)GenSendMsgTime;
@end

@interface CMessageMgr : NSObject
-(void)AddMsg:(id)arg1 MsgWrap:(id)arg2;
- (void)AsyncOnSpecialSession:(id)arg1 MsgList:(id)arg2;
- (id)GetHelloUsers:(id)arg1 Limit:(unsigned int)arg2 OnlyUnread:(_Bool)arg3;
// new
- (void)addAutoVerifyWithArray:(id)arg1;
- (void)sendMsg:(NSString *)msg toContact:(CPushContact *)contact;
@end

@interface FriendAsistSessionMgr : NSObject
- (id)GetLastMessage:(id)arg1 HelloUser:(id)arg2 OnlyTo:(_Bool)arg3;
@end

@interface AutoSetRemarkMgr : NSObject
- (id)GetStrangerAttribute:(id)arg1 AttributeName:(int)arg2;
@end

@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)service;
@end


#pragma mark - MODEL

@interface CMessageWrap : NSObject
- (id)initWithMsgType:(long long)arg1;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsDisplayName;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(nonatomic) unsigned int m_uiCreateTime; // @synthesize m_uiCreateTime;
@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
@end

@interface CBaseContact : NSObject
@property(retain, nonatomic) NSString *m_nsEncodeUserName; // @synthesize m_nsEncodeUserName;
@property(nonatomic) int m_uiFriendScene; // @synthesize m_uiFriendSce
@end

@interface CContact : CBaseContact
@end

@interface CPushContact : CContact
@property(retain, nonatomic) NSString *m_nsChatRoomUserName;
@property(retain, nonatomic) NSString *m_nsDes;
@property(retain, nonatomic) NSString *m_nsSource;
@property(retain, nonatomic) NSString *m_nsSourceNickName;
@property(retain, nonatomic) NSString *m_nsSourceUserName;
@property(retain, nonatomic) NSString *m_nsTicket;
@property(retain, nonatomic) NSString *m_nsUsrName;
-(BOOL)isMyContact;
@end

@interface CVerifyContactWrap : NSObject
@property(retain, nonatomic) NSString *m_nsChatRoomUserName;
@property(retain, nonatomic) NSString *m_nsOriginalUsrName;
@property(retain, nonatomic) NSString *m_nsSourceNickName;
@property(retain, nonatomic) NSString *m_nsSourceUserName;
@property(retain, nonatomic) NSString *m_nsTicket;
@property(retain, nonatomic) NSString *m_nsUsrName;
@property(retain, nonatomic) CContact *m_oVerifyContact;
@property(nonatomic) unsigned int m_uiScene;
@property(nonatomic) unsigned int m_uiWCFlag;
@end

#pragma mark - VC

@interface MMUIViewController : UIViewController
- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;
@end

@interface NewSettingViewController: MMUIViewController
- (void)reloadTableData;
@end

@interface SayHelloViewController : UIViewController
@property (nonatomic, copy) SayHelloDataLogic *m_DataLogic;
- (void)OnSayHelloDataVerifyContactOK:(CPushContact *)arg1;
@end

#pragma mark - Logic

@interface SayHelloDataLogic : NSObject
@property (nonatomic, copy) NSMutableArray *m_arrHellos;
- (void)loadData:(unsigned int)arg1;
+ (id)getContactFrom:(id)arg1;
- (id)getContactForIndex:(unsigned int)arg1;
- (void)onFriendAssistAddMsg:(NSArray *)arg1;
@end

@interface CContactVerifyLogic : NSObject
- (void)startWithVerifyContactWrap:(id)arg1
                            opCode:(unsigned int)arg2
                        parentView:(id)arg3
                      fromChatRoom:(_Bool)arg4;
@end


#pragma mark - MMTableView

@interface MMTableViewInfo
- (id)getTableView;
- (void)clearAllSection;
- (void)addSection:(id)arg1;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
@end

@interface MMTableViewSectionInfo
+ (id)sectionInfoDefaut;
+ (id)sectionInfoHeader:(id)arg1;
+ (id)sectionInfoHeader:(id)arg1 Footer:(id)arg2;
- (void)addCell:(id)arg1;
@end


@interface MMTableViewCellInfo
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 accessoryType:(long long)arg4;
+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(_Bool)arg4;
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 rightValue:(id)arg4 accessoryType:(long long)arg5;
+ (id)normalCellForTitle:(id)arg1 rightValue:(id)arg2;
+ (id)urlCellForTitle:(id)arg1 url:(id)arg2;
@end

@interface MMTableView: UITableView
@end

#pragma mark - UICategory

@interface UINavigationController (LogicController)
- (void)PushViewController:(id)arg1 animated:(_Bool)arg2;
@end


#pragma mark - UI

@interface MMUICommonUtil : NSObject
+ (id)getBarButtonWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4;
@end

@interface SettingUtil : NSObject
+ (id)getLocalUsrName:(unsigned int)arg1;
@end
