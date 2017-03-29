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

@end
