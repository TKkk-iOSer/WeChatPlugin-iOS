//
//  TKToast.m
//  WeChatRobot
//
//  Created by TK on 2017/4/5.
//  Copyright © 2017年 com.feibo.wechatrobot. All rights reserved.
//

#import "TKToast.h"
#import "WeChatRobot.h"

#define MARGIN_SIZE FIX_SIZE(10)

@interface TKToast()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TKToast

+ (void)toast:(NSString *)msg {
    [self toast:msg delay:1.5];
}

+ (void)toast:(NSString *)msg delay:(NSTimeInterval)duration {
    CGRect rect = [msg boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - MARGIN_SIZE * 4, 1000)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:TKFont(24), NSFontAttributeName, nil] context:nil];
    UILabel *label = ({
        UILabel *l = [[UILabel alloc] init];
        [l setBounds:CGRectMake(0, 0, rect.size.width + MARGIN_SIZE * 2, rect.size.height + MARGIN_SIZE * 2)];
        [l.layer setCornerRadius:FIX_SIZE(4)];
        [l.layer setMasksToBounds:YES];
        [l setBackgroundColor:RGBA(0, 0, 0, 0.6)];
        [l setAlpha:0.0f];
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setFont:TKFont(24)];
        [l setTextColor:[UIColor whiteColor]];
        [l setNumberOfLines:0];
        [l setText:msg];

        l;
    });

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [label setCenter:window.center];

    id temp = window.subviews.lastObject;
    if ([temp isMemberOfClass:[UILabel class]]) {
        [temp removeFromSuperview];
    }

    [window addSubview:label];

    [UIView animateWithDuration:0.2 animations:^{
        [label setAlpha:1.0f];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                [label setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        });
    }];
}

@end
