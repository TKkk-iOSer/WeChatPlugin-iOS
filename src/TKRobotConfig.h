//
//  TKRobotConfig.h
//  WeChatRobot
//
//  Created by TK on 2017/3/27.
//  Copyright © 2017年 TK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKRobotConfig : NSObject

+ (instancetype)sharedConfig;

/**
  自动确认好友请求

*/
@property (nonatomic, assign) BOOL autoVerifyEnable;
@property (nonatomic, copy) NSString *autoVerifyKeyword;            /**<    自动验证关键字  */

/**
 确认好友请求以后，自动发送欢迎语

*/
@property (nonatomic, assign) BOOL welcomeEnable;
@property (nonatomic, copy) NSString *welcomeText;                   /**<    好友通过欢迎语  */

/**
特定消息自动回复

*/
@property (nonatomic, assign) BOOL autoReplyEnable;
@property (nonatomic, copy) NSString *autoReplyKeyword;             /**<    自动回复关键字  */
@property (nonatomic, copy) NSString *autoReplyText;                /**<    自动回复的内容  */

/**
 给好友群发消息

 */
@property (nonatomic, copy) NSString *groupSendText;                /**<    群发的消息内容  */

/**
 入群欢迎语

 */
@property (nonatomic, assign) BOOL welcomeJoinChatRoomEnable;
@property (nonatomic, copy) NSString *welcomeJoinChatRoomText;      /**<    入群欢迎语     */

@end
