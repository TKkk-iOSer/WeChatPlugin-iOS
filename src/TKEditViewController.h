//
//  TKEditViewController.h
//  WeChatRobot
//
//  Created by TK on 2017/3/31.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "WeChatRobot.h"

@interface TKEditViewController : UIViewController

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) void (^endEditing)(NSString *text);

@end
