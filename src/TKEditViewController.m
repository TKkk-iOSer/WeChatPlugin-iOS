//
//  TKEditViewController.m
//  WeChatRobot
//
//  Created by TK on 2017/3/31.
//  Copyright © 2017年 TK. All rights reserved.
//

#import "TKEditViewController.h"

@interface TKEditViewController ()

@property (nonatomic, strong) MMTextView *textView;

@end

@implementation TKEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initNav];
    [self initSubviews];
    [self setup];
}

- (void)initNav {
    self.navigationItem.leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"返回" target:self action:@selector(onBack) style:3];
    self.navigationItem.rightBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@"完成" target:self action:@selector(onFinfsh) style:4];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)initSubviews {
    self.textView = ({
        MMTextView *tv = [[objc_getClass("MMTextView") alloc] initWithFrame:CGRectMake(7, 0, SCREEN_WIDTH - 14, SCREEN_HEIGHT)];
        tv.font = [UIFont systemFontOfSize:16];

        tv;
    });

    [self.view addSubview:self.textView];
}

- (void)setup {
    self.textView.text = self.text;
    self.textView.placeholder = self.placeholder;
    self.view.backgroundColor = [UIColor whiteColor];

    [self.textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyBoardChange:(NSNotification *)note {
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    if (keyboardFrame.origin.y < SCREEN_HEIGHT) {
        self.textView.frame = CGRectMake(7, 0, SCREEN_WIDTH - 14, SCREEN_HEIGHT - keyboardFrame.size.height);
    } else {
        self.textView.frame = CGRectMake(7, 0, SCREEN_WIDTH - 14, SCREEN_HEIGHT);
    }
}

- (void)onBack {
    if (self.textView.text.length > 0 && ![self.textView.text isEqualToString:self.text]) {
        [self alertControllerWithTitle:@"确定不保存返回么"
                               message:nil
                             leftBlock:nil
                            rightBlock:^() {
                                [self.view endEditing:YES];
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    } else {
        [self.view endEditing:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onFinfsh {
    [self.view endEditing:YES];
    if (self.endEditing) {
        self.endEditing(self.textView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message leftBlock:(void (^)(void))leftBlk  rightBlock:(void (^)(void))rightBlk {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:nil
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (leftBlk) {
                                                        leftBlk();
                                                    }
                                                }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (rightBlk) {
                                                        rightBlk();
                                                    }
                                                }]];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
