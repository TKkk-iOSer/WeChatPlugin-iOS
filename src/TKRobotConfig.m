//
//  TKRobotConfig.m
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKRobotConfig.h"

static NSString * const KTKAutoVerifyEnableKey = @"kTKAutoVerifyEnableKey";
static NSString * const kTKAutoVerifyKeywordKey = @"kTKAutoVerifyKeywordKey";

static NSString * const kTKWelcomeEnableKey = @"kTKWelcomeEnableKey";
static NSString * const kTKWelcomeTextKey = @"kTKWelcomeTextKey";

static NSString * const kTKAutoReplyEnableKey = @"kTKAutoReplyEnableKey";
static NSString * const kTKAutoReplyKeywordKey = @"kTKAutoReplyKeywordKey";
static NSString * const kTKAutoReplyTextKey = @"kTKAutoReplyTextKey";

static NSString * const kTKGroupSendTextKey = @"kTKGroupSendTextKey";

static NSString * const kTKWelcomeJoinChatRoomEnableKey = @"kTKWelcomeJoinChatRoomEnableKey";
static NSString * const kTKWelcomeJoinChatRoomTextKey = @"kTKWelcomeJoinChatRoomTextKey";

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
        _autoVerifyEnable = [[NSUserDefaults standardUserDefaults] boolForKey:KTKAutoVerifyEnableKey];
        _autoVerifyKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoVerifyKeywordKey];
        _welcomeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKWelcomeEnableKey];
        _welcomeText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKWelcomeTextKey];
        _autoReplyEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKAutoReplyEnableKey];
        _autoReplyKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyKeywordKey];
        _autoReplyText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyTextKey];
//        _groupSendEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKGroupSendEnableKey];
        _groupSendText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKGroupSendTextKey];
        _welcomeJoinChatRoomEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKWelcomeJoinChatRoomEnableKey];
        _welcomeJoinChatRoomText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKWelcomeJoinChatRoomTextKey];
    }
    return self;
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

- (void)setWelcomeEnable:(BOOL)welcomeEnable {
    _welcomeEnable = welcomeEnable;
    [[NSUserDefaults standardUserDefaults] setBool:welcomeEnable forKey:kTKWelcomeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWelcomeText:(NSString *)welcomeText {
    _welcomeText = welcomeText;
    [[NSUserDefaults standardUserDefaults] setObject:welcomeText forKey:kTKWelcomeTextKey];
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

- (void)setGroupSendText:(NSString *)groupSendText {
    _groupSendText = groupSendText;
    [[NSUserDefaults standardUserDefaults] setObject:groupSendText forKey:kTKGroupSendTextKey];
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

@end
