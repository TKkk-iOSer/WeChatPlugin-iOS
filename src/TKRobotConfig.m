//
//  TKRobotConfig.m
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKRobotConfig.h"

static NSString * const kAutoContactVerifyTextKey = @"kAutoContactVerifyTextKey";

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
        _autoContactVerifyText = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoContactVerifyTextKey];
    }
    return self;
}

- (void)setAutoContactVerifyText:(NSString *)autoContactVerifyText {
    _autoContactVerifyText = autoContactVerifyText;
    [[NSUserDefaults standardUserDefaults] setObject:autoContactVerifyText forKey:kAutoContactVerifyTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
