//
//  EmoticonGameCheat.m
//
//  Created by lanjuzi on 2017/9/22.
//  Copyright © 2017年 lanjuzi. All rights reserved.
//

#import "EmoticonGameCheat.h"

@implementation EmoticonGameCheat

+ (void)showEoticonCheat:(NSInteger)uiGameType callback:(void (^)(NSInteger random))callback {
    NSArray *array;
    if (uiGameType == 1) {
        array = @[@[@1, @"剪刀"], @[@2, @"石头"], @[@3, @"布"]];
    } else if (uiGameType == 2) {
        array = @[@[@4, @"1"], @[@5, @"2"], @[@6, @"3"], @[@7, @"4"], @[@8, @"5"], @[@9, @"6"]];
    } else {
        NSLog(@"不支持的 uiGameType 类型: %ld", (long)uiGameType);
        return;
    }

    CGRect frame = [[UIApplication sharedApplication] keyWindow].rootViewController.view.frame;
    zhFullView *fullView = [[zhFullView alloc] initWithFrame:frame andRows:uiGameType];

    NSMutableArray *models = [NSMutableArray arrayWithCapacity:array.count];
    for (NSArray *arr in array) {
        zhIconLabelModel *item = [zhIconLabelModel new];

        if ([arr[0] intValue] > 0) {
            if ([arr[0] intValue] > 3) {
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"dice_%@", arr[1]] ofType:@"pic"];
                item.icon = [UIImage imageWithContentsOfFile:imagePath];
            } else {
                NSString *jsb;
                switch ([arr[0] intValue]) {
                    case 1:
                        jsb = @"JSB_J";
                        break;
                    case 2:
                        jsb = @"JSB_S";
                        break;
                    case 3:
                        jsb = @"JSB_B";
                        break;
                    default:
                        jsb = @"JSB_S";
                        break;
                }
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:jsb ofType:@"pic"];
                item.icon = [UIImage imageWithContentsOfFile:imagePath];
            }
        }
        item.text = arr[1];
        [models addObject:item];
    }
    fullView.models = models;

    fullView.didClickFullView = ^(zhFullView * _Nonnull fullView) {
        [self.zh_popupController dismiss];
    };

    fullView.didClickItems = ^(zhFullView *fullView, NSInteger index) {
        self.zh_popupController.didDismiss = ^(zhPopupController * _Nonnull popupController) {
            callback([array[index][0] intValue]);
        };

        [fullView endAnimationsCompletion:^(zhFullView *fullView) {
            [self.zh_popupController dismiss];
        }];
    };

    self.zh_popupController = [zhPopupController popupControllerWithMaskType:zhPopupMaskTypeWhiteBlur];
    self.zh_popupController.allowPan = YES;
    [self.zh_popupController presentContentView:fullView];
}

@end

