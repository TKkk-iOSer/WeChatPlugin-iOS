//
//  TKRobotConfig.m
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKRobotConfig.h"

static NSString * const kTKAutoContactVerifyTextKey = @"kTKAutoContactVerifyTextKey";
static NSString * const kTKWelcomesTextKey = @"kTKWelcomesTextKey";
static NSString * const kTKNeedAutoReplyMsgKey = @"kTKNeedAutoReplyMsgKey";
static NSString * const kTKAutoReplyContentKey = @"kTKAutoReplyContentKey";

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
        _autoContactVerifyText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoContactVerifyTextKey];
        _welcomesText = [[NSUserDefaults standardUserDefaults] objectForKey:kTKWelcomesTextKey];
        _needAutoReplyMsg = [[NSUserDefaults standardUserDefaults] objectForKey:kTKNeedAutoReplyMsgKey];
        _autoReplyContent = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyContentKey];

    }
    return self;
}

- (void)setAutoContactVerifyText:(NSString *)autoContactVerifyText {
    _autoContactVerifyText = autoContactVerifyText;
    [[NSUserDefaults standardUserDefaults] setObject:autoContactVerifyText forKey:kTKAutoContactVerifyTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setWelcomesText:(NSString *)welcomesText {
    _welcomesText = welcomesText;
    [[NSUserDefaults standardUserDefaults] setObject:welcomesText forKey:kTKWelcomesTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNeedAutoReplyMsg:(NSString *)needAutoReplyMsg {
    _needAutoReplyMsg = needAutoReplyMsg;
    [[NSUserDefaults standardUserDefaults] setObject:needAutoReplyMsg forKey:kTKNeedAutoReplyMsgKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyContent:(NSString *)autoReplyContent {
    _autoReplyContent = autoReplyContent;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyContent forKey:kTKAutoReplyContentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
