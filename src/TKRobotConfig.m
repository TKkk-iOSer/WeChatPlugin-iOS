//
//  TKRobotConfig.m
//  WeChatRobot
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKRobotConfig.h"

static NSString * const KTKPreventGameCheatEnableKey = @"KTKPreventGameCheatEnableKey";
static NSString * const KTKPreventRevokeEnableKey = @"KTKPreventRevokeEnableKey";
static NSString * const KTKChangeStepEnableKey = @"KTKChangeStepEnableKey";
static NSString * const kTKDeviceStepKey = @"kTKDeviceStepKey";
static NSString * const KTKAutoVerifyEnableKey = @"kTKAutoVerifyEnableKey";
static NSString * const kTKAutoVerifyKeywordKey = @"kTKAutoVerifyKeywordKey";
static NSString * const KTKAutoWelcomeEnableKey = @"KTKAutoWelcomeEnableKey";
static NSString * const kTKAutoWelcomeTextKey = @"kTKAutoWelcomeTextKey";
static NSString * const kTKAutoReplyEnableKey = @"kTKAutoReplyEnableKey";
static NSString * const kTKAutoReplyKeywordKey = @"kTKAutoReplyKeywordKey";
static NSString * const kTKAutoReplyTextKey = @"kTKAutoReplyTextKey";
static NSString * const kTKAutoReplyChatRoomEnableKey = @"kTKAutoReplyChatRoomEnableKey";
static NSString * const kTKAutoReplyChatRoomKeywordKey = @"kTKAutoReplyChatRoomKeywordKey";
static NSString * const kTKAutoReplyChatRoomTextKey = @"kTKAutoReplyChatRoomTextKey";
static NSString * const kTKWelcomeJoinChatRoomEnableKey = @"kTKWelcomeJoinChatRoomEnableKey";
static NSString * const kTKWelcomeJoinChatRoomTextKey = @"kTKWelcomeJoinChatRoomTextKey";
static NSString * const kTKAllChatRoomDescTextKey = @"kTKAllChatRoomDescTextKey";
static NSString * const kTKChatRoomSensitiveEnableKey = @"kTKChatRoomSensitiveEnableKey";
static NSString * const kTKChatRoomSensitiveArrayKey = @"kTKChatRoomSensitiveArrayKey";

@implementation TKRobotConfig

+ (instancetype)sharedConfig {
    static TKRobotConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[TKRobotConfig alloc] init];
    });

    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _preventGameCheatEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKPreventGameCheatEnableKey];
        _preventRevokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKPreventRevokeEnableKey];
        _changeStepEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKChangeStepEnableKey];
        _deviceStep = [[[NSUserDefaults standardUserDefaults] objectForKey:kTKDeviceStepKey] intValue];
        _autoVerifyEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKAutoVerifyEnableKey];
        _autoVerifyKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoVerifyKeywordKey];
        _autoWelcomeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKAutoWelcomeEnableKey];
        _autoWelcomeText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoWelcomeTextKey];
        _autoReplyEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKAutoReplyEnableKey];
        _autoReplyKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyKeywordKey];
        _autoReplyText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyTextKey];
        _autoReplyChatRoomEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKAutoReplyChatRoomEnableKey];
        _autoReplyChatRoomKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyChatRoomKeywordKey];
        _autoReplyChatRoomText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyChatRoomTextKey];
        _welcomeJoinChatRoomEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKWelcomeJoinChatRoomEnableKey];
        _welcomeJoinChatRoomText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKWelcomeJoinChatRoomTextKey];
        _allChatRoomDescText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAllChatRoomDescTextKey];
        _chatRoomSensitiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKChatRoomSensitiveEnableKey];
        _chatRoomSensitiveArray = [[NSUserDefaults standardUserDefaults] objectForKey:kTKChatRoomSensitiveArrayKey];
    }
    return self;
}

- (void)setPreventGameCheatEnable:(BOOL)preventGameCheatEnable {
    _preventGameCheatEnable = preventGameCheatEnable;
    [[NSUserDefaults standardUserDefaults] setBool:preventGameCheatEnable forKey:KTKPreventGameCheatEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPreventRevokeEnable:(BOOL)preventRevokeEnable {
    _preventRevokeEnable = preventRevokeEnable;
    [[NSUserDefaults standardUserDefaults] setBool:preventRevokeEnable forKey:KTKPreventRevokeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setChangeStepEnable:(BOOL)changeStepEnable {
    _changeStepEnable = changeStepEnable;
    [[NSUserDefaults standardUserDefaults] setBool:changeStepEnable forKey:KTKChangeStepEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDeviceStep:(NSInteger)deviceStep {
    _deviceStep = deviceStep;
    [[NSUserDefaults standardUserDefaults] setObject:@(deviceStep) forKey:kTKDeviceStepKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoVerifyEnable:(BOOL)autoVerifyEnable {
    _autoVerifyEnable = autoVerifyEnable;
    [[NSUserDefaults standardUserDefaults] setBool:autoVerifyEnable forKey:KTKAutoVerifyEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoVerifyKeyword:(NSString *)autoVerifyKeyword {
    _autoVerifyKeyword = autoVerifyKeyword;
    [[NSUserDefaults standardUserDefaults] setObject:autoVerifyKeyword forKey:kTKAutoVerifyKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoWelcomeEnable:(BOOL)autoWelcomeEnable {
    _autoWelcomeEnable = autoWelcomeEnable;
    [[NSUserDefaults standardUserDefaults] setBool:autoWelcomeEnable forKey:KTKAutoWelcomeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoWelcomeText:(NSString *)autoWelcomeText {
    _autoWelcomeText = autoWelcomeText;
    [[NSUserDefaults standardUserDefaults] setObject:autoWelcomeText forKey:kTKAutoWelcomeTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyEnable:(BOOL)autoReplyEnable {
    _autoReplyEnable = autoReplyEnable;
    [[NSUserDefaults standardUserDefaults] setBool:autoReplyEnable forKey:kTKAutoReplyEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyKeyword:(NSString *)autoReplyKeyword {
    _autoReplyKeyword = autoReplyKeyword;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyKeyword forKey:kTKAutoReplyKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyText:(NSString *)autoReplyText {
    _autoReplyText = autoReplyText;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyText forKey:kTKAutoReplyTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyChatRoomEnable:(BOOL)autoReplyChatRoomEnable {
    _autoReplyChatRoomEnable = autoReplyChatRoomEnable;
    [[NSUserDefaults standardUserDefaults] setBool:autoReplyChatRoomEnable forKey:kTKAutoReplyChatRoomEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyChatRoomKeyword:(NSString *)autoReplyChatRoomKeyword {
    _autoReplyChatRoomKeyword = autoReplyChatRoomKeyword;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyChatRoomKeyword forKey:kTKAutoReplyChatRoomKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyChatRoomText:(NSString *)autoReplyChatRoomText {
    _autoReplyChatRoomText = autoReplyChatRoomText;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyChatRoomText forKey:kTKAutoReplyChatRoomTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWelcomeJoinChatRoomEnable:(BOOL)welcomeJoinChatRoomEnable {
    _welcomeJoinChatRoomEnable = welcomeJoinChatRoomEnable;
    [[NSUserDefaults standardUserDefaults] setBool:welcomeJoinChatRoomEnable forKey:kTKWelcomeJoinChatRoomEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWelcomeJoinChatRoomText:(NSString *)welcomeJoinChatRoomText {
    _welcomeJoinChatRoomText = welcomeJoinChatRoomText;
    [[NSUserDefaults standardUserDefaults] setObject:welcomeJoinChatRoomText forKey:kTKWelcomeJoinChatRoomTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAllChatRoomDescText:(NSString *)allChatRoomDescText {
    _allChatRoomDescText = [allChatRoomDescText copy];
    [[NSUserDefaults standardUserDefaults] setObject:_allChatRoomDescText forKey:kTKAllChatRoomDescTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setChatRoomSensitiveEnable:(BOOL)chatRoomSensitiveEnable {
    _chatRoomSensitiveEnable = chatRoomSensitiveEnable;
    [[NSUserDefaults standardUserDefaults] setBool:chatRoomSensitiveEnable forKey:kTKChatRoomSensitiveEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setChatRoomSensitiveArray:(NSMutableArray *)chatRoomSensitiveArray {
    _chatRoomSensitiveArray = chatRoomSensitiveArray;
    [[NSUserDefaults standardUserDefaults] setObject:chatRoomSensitiveArray forKey:kTKChatRoomSensitiveArrayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
