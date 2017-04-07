//
//  TKToast.h
//  WeChatRobot
//
//  Created by TK on 2017/4/7.
//  Copyright © 2017年 com.feibo.wechatrobot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKToast : NSObject

+ (void)toast:(NSString *)msg;
+ (void)toast:(NSString *)msg delay:(NSTimeInterval)duration;

@end
