//
//  TKRobotConfig.h
//  Demo
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKRobotConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic, copy) NSString *autoContactVerifyText;
@property (nonatomic, copy) NSString *welcomesText;

@end
