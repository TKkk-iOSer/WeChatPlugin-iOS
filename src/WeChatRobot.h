//
//  WeChatRobot.h
//  WeChatRobot
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKEditViewController.h"
#import "TKRobotConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TKToast.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//适配IP6和6+的等比放大效果
#define FIX_SIZE(num) ((num) * SCREEN_WIDTH / 320.0)
#define FIX_FONT_SIZE(size) SCREEN_WIDTH < 375 ? ((size + 4.0) / 2.0) : SCREEN_WIDTH == 375 ? ((size + 8.0) / 2.0) : ((size + 12.0) / 2.0)
#define TKFont(size) [UIFont systemFontOfSize:FIX_FONT_SIZE(size)]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define RGB(r, g, b) RGBA(r, g, b, 1)

typedef NS_ENUM(NSUInteger, TKArrayTpye) {
    TKArrayTpyeMsgWrap,
    TKArrayTpyeMsgUserName
};

@class MMTableViewInfo;

#pragma mark - MODEL

@interface CMessageWrap : NSObject
@property(nonatomic, assign) NSInteger m_uiGameType;  // 1、猜拳; 2、骰子; 0、自定义表情
@property(nonatomic, assign) unsigned long m_uiGameContent;
@property(nonatomic, strong) NSString *m_nsEmoticonMD5;
@property(nonatomic) long long m_n64MesSvrID;
@property (nonatomic, copy) NSString *m_nsContent;                      // 内容
@property (nonatomic, copy) NSString *m_nsToUsr;                        // 接收的用户(微信id)
@property (nonatomic, copy) NSString *m_nsFromUsr;                      // 发送的用户(微信id)
@property (nonatomic, copy) NSString *m_nsLastDisplayContent;
@property (nonatomic, assign) unsigned int m_uiCreateTime;               // 消息生成时间
@property (nonatomic, assign) unsigned int m_uiStatus;                   // 消息状态
@property (nonatomic, assign) int m_uiMessageType;                       // 消息类型
@property (nonatomic, copy) NSString *m_nsRealChatUsr;
@property (nonatomic, copy) NSString *m_nsPushContent;
- (id)initWithMsgType:(long long)arg1;
@end

@interface CBaseContact : NSObject
@property (nonatomic, copy) NSString *m_nsEncodeUserName;                // 微信用户名转码
@property (nonatomic, assign) int m_uiFriendScene;                       // 是否是自己的好友(非订阅号、自己)
@property (nonatomic,assign) BOOL m_isPlugin;                            // 是否为微信插件
- (BOOL)isChatroom;
@end

@interface CContact : CBaseContact
@property (nonatomic, copy) NSString *m_nsOwner;                        // 拥有者
@property (nonatomic, copy) NSString *m_nsNickName;                     // 用户昵称
@property (nonatomic, copy) NSString *m_nsUsrName;                      // 微信id
@property (nonatomic, copy) NSString *m_nsMemberName;
@end

@interface CPushContact : CContact
@property (nonatomic, copy) NSString *m_nsChatRoomUserName;
@property (nonatomic, copy) NSString *m_nsDes;
@property (nonatomic, copy) NSString *m_nsSource;
@property (nonatomic, copy) NSString *m_nsSourceNickName;
@property (nonatomic, copy) NSString *m_nsSourceUserName;
@property (nonatomic, copy) NSString *m_nsTicket;
- (BOOL)isMyContact;
@end

@interface CVerifyContactWrap : NSObject
@property (nonatomic, copy) NSString *m_nsChatRoomUserName;
@property (nonatomic, copy) NSString *m_nsOriginalUsrName;
@property (nonatomic, copy) NSString *m_nsSourceNickName;
@property (nonatomic, copy) NSString *m_nsSourceUserName;
@property (nonatomic, copy) NSString *m_nsTicket;
@property (nonatomic, copy) NSString *m_nsUsrName;
@property (nonatomic, strong) CContact *m_oVerifyContact;
@property (nonatomic, assign) unsigned int m_uiScene;
@property (nonatomic, assign) unsigned int m_uiWCFlag;
@end


@interface GroupMember : NSObject
@property(copy, nonatomic) NSString *m_nsNickName;; // @synthesize m_nsNickName;
@property(nonatomic) unsigned int m_uiMemberStatus; // @synthesize m_uiMemberStatus;
@property(copy, nonatomic) NSString *m_nsMemberName; // @synthesize m_nsMemberName;
@end


#pragma mark - Logic

@interface SayHelloDataLogic : NSObject
@property (nonatomic, strong) NSMutableArray *m_arrHellos;
- (void)loadData:(unsigned int)arg1;
+ (id)getContactFrom:(id)arg1;
- (id)getContactForIndex:(unsigned int)arg1;
- (void)onFriendAssistAddMsg:(NSArray *)arg1;
@end

@interface CContactVerifyLogic : NSObject
- (void)startWithVerifyContactWrap:(id)arg1
                            opCode:(unsigned int)arg2
                        parentView:(id)arg3
                      fromChatRoom:(BOOL)arg4;
@end

@interface ContactsDataLogic : NSObject
- (id)getKeysArray;
- (BOOL)reloadContacts;
- (BOOL)hasHistoryGroupContacts;
- (id)getContactsArrayWith:(id)arg1;
- (id)initWithScene:(unsigned int)arg1 delegate:(id)arg2 sort:(BOOL)arg3;
@end

@interface SKBuiltinString_t : NSObject
// Remaining properties
@property(copy, nonatomic) NSString *string; // @dynamic string;
@end

@interface CreateChatRoomResponse : NSObject
@property(strong, nonatomic) SKBuiltinString_t *chatRoomName; // @dynamic chatRoomName;
@end

#pragma mark - Manager

@interface MMNewSessionMgr : NSObject
- (unsigned int)GenSendMsgTime;
@end

@interface CMessageMgr : NSObject
- (id)GetMsg:(id)arg1 n64SvrID:(long long)arg2;
- (void)onRevokeMsg:(id)msg;
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2;
- (void)AddLocalMsg:(id)arg1 MsgWrap:(id)arg2 fixTime:(_Bool)arg3 NewMsgArriveNotify:(_Bool)arg4;
- (void)AsyncOnSpecialSession:(id)arg1 MsgList:(id)arg2;
- (id)GetHelloUsers:(id)arg1 Limit:(unsigned int)arg2 OnlyUnread:(BOOL)arg3;
- (void)AddEmoticonMsg:(NSString *)msg MsgWrap:(CMessageWrap *)msgWrap;
// new
- (void)addAutoVerifyWithArray:(NSArray *)ary arrayType:(TKArrayTpye)type;
- (void)addAutoVerifyWithMessageInfo:(NSDictionary *)info;
- (void)autoReplyWithMessageWrap:(CMessageWrap *)wrap;
- (void)autoReplyChatRoomWithMessageWrap:(CMessageWrap *)wrap;
- (void)sendMsg:(NSString *)msg toContactUsrName:(NSString *)userName;
- (void)welcomeJoinChatRoomWithMessageWrap:(CMessageWrap *)wrap;
- (void)removeMemberWithMessageWrap:(CMessageWrap *)wrap;
@end

@interface FriendAsistSessionMgr : NSObject
- (id)GetLastMessage:(id)arg1 HelloUser:(id)arg2 OnlyTo:(BOOL)arg3;
@end

@interface AutoSetRemarkMgr : NSObject
- (id)GetStrangerAttribute:(id)arg1 AttributeName:(int)arg2;
@end

@interface CContactMgr : NSObject
- (id)getSelfContact;
- (id)getContactByName:(id)arg1;
- (id)getContactList:(unsigned int)arg1 contactType:(unsigned int)arg2;
@end

@interface MMServiceCenter : NSObject
+ (instancetype)defaultCenter;
- (id)getService:(Class)service;
@end

@interface CGroupMgr : NSObject
- (BOOL)SetChatRoomDesc:(id)arg1 Desc:(id)arg2 Flag:(unsigned int)arg3;
- (BOOL)CreateGroup:(id)arg1 withMemberList:(id)arg2;
- (_Bool)DeleteGroupMember:(id)arg1 withMemberList:(id)arg2 scene:(unsigned long long)arg3;
@end

#pragma mark - ViewController

@interface MMUIViewController : UIViewController
@end

@interface NewSettingViewController: MMUIViewController

@property(nonatomic, strong) MMTableViewInfo *m_tableViewInfo; //
- (void)reloadTableData;
@end

@interface SayHelloViewController : UIViewController
@property (nonatomic, strong) SayHelloDataLogic *m_DataLogic;
- (void)OnSayHelloDataVerifyContactOK:(CPushContact *)arg1;
@end

#pragma mark - MMTableView

@interface MMTableViewInfo
- (id)getTableView;
- (void)clearAllSection;
- (void)addSection:(id)arg1;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
- (id)getSectionAt:(unsigned int)arg1;
@property(nonatomic,assign) id delegate;
@end

@interface MMTableViewSectionInfo : NSObject
+ (id)sectionInfoDefaut;
+ (id)sectionInfoHeader:(id)arg1;
+ (id)sectionInfoHeader:(id)arg1 Footer:(id)arg2;
- (void)addCell:(id)arg1;
- (void)removeCellAt:(unsigned long long)arg1;
- (unsigned long long)getCellCount;
@end

@interface MMTableViewCellInfo
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 accessoryType:(long long)arg4;
+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(BOOL)arg4;
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 rightValue:(id)arg4 accessoryType:(long long)arg5;
+ (id)editorCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 margin:(double)arg4 tip:(id)arg5 focus:(_Bool)arg6 text:(id)arg7;
+ (id)normalCellForTitle:(id)arg1 rightValue:(id)arg2;
+ (id)urlCellForTitle:(id)arg1 url:(id)arg2;
@property(nonatomic) long long editStyle; // @synthesize editStyle=_editStyle;
@property(retain, nonatomic) id userInfo;
@end

@interface MMTableView: UITableView
@end

#pragma mark - UI

@interface MMLoadingView : UIView
- (void)setFitFrame:(long long)arg1;
- (void)startLoading;
- (void)stopLoading;
- (void)stopLoadingAndShowError:(id)arg1;
- (void)stopLoadingAndShowOK:(id)arg1;
@property(retain, nonatomic) UILabel *m_label;
@property (assign, nonatomic) BOOL m_bIgnoringInteractionEventsWhenLoading;
@end

@interface MMTextView : UITextView
@property(retain, nonatomic) NSString *placeholder;
@end

@interface MMUICommonUtil : NSObject
+ (id)getBarButtonWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4;
@end

@interface SettingUtil : NSObject
+ (id)getLocalUsrName:(unsigned int)arg1;
@end

@interface ContactSelectView : UIView
@property(nonatomic) _Bool m_bShowHistoryGroup; // @synthesize m_bShowHistoryGroup;
@property(nonatomic) _Bool m_bShowRadarCreateRoom; // @synthesize m_bShowRadarCreateRoom;
@property(nonatomic) _Bool m_bMultiSelect; // @synthesize m_bMultiSelect;
@property(retain, nonatomic) NSDictionary *m_dicExistContact; // @synthesize m_dicExistContact;
@property(retain, nonatomic) NSMutableDictionary *m_dicMultiSelect; // @synthesize m_dicMultiSelect;
@property(nonatomic) unsigned int m_uiGroupScene; // @synthesize m_uiGroupScene;
- (void)initView;
- (void)initSearchBar;
- (void)initData:(unsigned int)arg1;
- (void)makeGroupCell:(id)arg1 head:(id)arg2 title:(id)arg3;
- (void)addSelect:(id)arg1;
@end

#pragma mark - UICategory

@interface UINavigationController (LogicController)
- (void)PushViewController:(id)arg1 animated:(BOOL)arg2;
@end

@interface GameController : NSObject
+ (NSString*)getMD5ByGameContent:(NSInteger) content;
@end
