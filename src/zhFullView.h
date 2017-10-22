//
//  zhFullView.h
//  zhPopupControllerDemo
//
//  Created by zhanghao on 2016/12/27.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class zhIconLabel, zhIconLabelModel;

@interface zhFullView : UIView

@property (assign) NSInteger rowCount;   // 每行显示数
@property (assign) NSInteger rows;   // 每页显示行数

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSArray<zhIconLabelModel *> *models;
@property (nonatomic, strong, readonly) NSMutableArray<zhIconLabel *> *items;

@property (nonatomic, copy) void (^didClickFullView)(zhFullView *fullView);
@property (nonatomic, copy) void (^didClickItems)(zhFullView *fullView, NSInteger index);

- (void)endAnimationsCompletion:(void (^)(zhFullView *fullView))completion; // 动画结束后执行block

- (instancetype)initWithFrame:(CGRect)frame andRows:(NSInteger)row;

@end

