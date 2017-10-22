//
//  zhIconLabel.h
//  zhPopupControllerDemo
//
//  Created by zhanghao on 2016/9/26.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class zhIconLabelModel;

@interface zhIconLabel : UIControl

@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UILabel *textLabel;

// UIEdgeInsets insets = {top, left, bottom, right}
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets; // default = UIEdgeInsetsZero 使用insets.bottom或insets.right来调整间距

@property (nonatomic, assign) BOOL horizontalLayout; // default is NO.

@property (nonatomic, assign) BOOL autoresizingFlexibleSize; // default is NO. 根据内容适应自身高度

@property (nonatomic, assign) CGFloat sizeLimit; // textLabel根据文本计算size时，如果纵向布局则限高，横向布局则限宽

@property (nonatomic, strong) zhIconLabelModel *model;

- (void)updateLayoutBySize:(CGSize)size finished:(void (^)(zhIconLabel *item))finished; // 属性赋值后需更新布局

@end

@interface zhIconLabelModel : NSObject

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *text;

+ (instancetype)modelWithTitle:(NSString *)title image:(UIImage *)image;

@end
