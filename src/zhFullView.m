//
//  zhFullView.m
//  zhPopupControllerDemo
//
//  Created by zhanghao on 2016/12/27.
//  Copyright © 2017年 zhanghao. All rights reserved.
//

#import "zhFullView.h"
#import "UIColor+Extend.h"
#import "UIView+Layout.h"
#import "UIScreen+Extend.h"
#import "zhIconLabel.h"

@interface zhFullView () <UIScrollViewDelegate> {
    CGFloat _gap, _space;
}
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *closeIcon;
@property (nonatomic, strong) UIScrollView *scrollContainer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *pageViews;

@end

@implementation zhFullView

@synthesize rowCount;
@synthesize rows;

- (instancetype)initWithFrame:(CGRect)frame andRows:(NSInteger)row {
    if (self = [super initWithFrame:frame]) {
        self.rowCount = 3;
        self.rows = row;

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullViewClicked:)]];

        _closeButton = [UIButton new];
        _closeButton.backgroundColor = [UIColor whiteColor];
        _closeButton.userInteractionEnabled = NO;
        [_closeButton addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];

        _closeIcon = [UIButton new];
        _closeIcon.userInteractionEnabled = NO;
        _closeIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_closeIcon setImage:[UIImage imageNamed:@"popup_close_btn"] forState:UIControlStateNormal];
        [self addSubview:_closeIcon];

        [self setContent];
        [self commonInitialization];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero andRows:1];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andRows:1];
}

- (void)setContent {
    _closeButton.size = CGSizeMake([UIScreen width], 44);
    _closeButton.bottom = [UIScreen height];
    _closeIcon.size = CGSizeMake(30, 30);
    _closeIcon.center = _closeButton.center;
}

- (void)commonInitialization {
    _scrollContainer = [UIScrollView new];
    _scrollContainer.bounces = NO;
    _scrollContainer.pagingEnabled = YES;
    _scrollContainer.showsHorizontalScrollIndicator = NO;
    _scrollContainer.delaysContentTouches = YES;
    _scrollContainer.delegate = self;
    [self addSubview:_scrollContainer];

    _itemSize = CGSizeMake(60, 95);
    _gap = 15;
    _space = ([UIScreen width] - self.rowCount * _itemSize.width) / (self.rowCount + 1);

    _scrollContainer.size = CGSizeMake([UIScreen width], _itemSize.height * self.rows + _gap  + 150);
    _scrollContainer.bottom = [UIScreen height] - _closeButton.height;
    _scrollContainer.contentSize = CGSizeMake([UIScreen width], _scrollContainer.height);

    _pageViews = @[].mutableCopy;
    UIImageView *pageView = [UIImageView new];
    pageView.size = _scrollContainer.size;
    pageView.x = 0;
    pageView.userInteractionEnabled = YES;
    [_scrollContainer addSubview:pageView];
    [_pageViews addObject:pageView];
}

- (void)setModels:(NSArray<zhIconLabelModel *> *)models {
    _items = @[].mutableCopy;
    [_pageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i = 0; i < self.rows * self.rowCount; i++) {
            NSInteger l = i % self.rowCount;
            NSInteger v = i / self.rowCount;

            zhIconLabel *item = [zhIconLabel new];
            [imageView addSubview:item];
            [_items addObject:item];
            item.tag = i + idx * (self.rows *self.rowCount);
            if (item.tag < models.count) {
                [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked:)]];
                item.model = [models objectAtIndex:item.tag];
                item.iconView.userInteractionEnabled = NO;
                item.textLabel.font = [UIFont systemFontOfSize:14];
                item.textLabel.textColor = [UIColor r:82 g:82 b:82];
                [item updateLayoutBySize:_itemSize finished:^(zhIconLabel *item) {
                    item.x = _space + (_itemSize.width  + _space) * l;
                    item.y = (_itemSize.height + _gap) * v + _gap + 100;
                }];
            }
        }
    }];
    _models = models;
    [self startAnimationsCompletion:NULL];
}

- (void)fullViewClicked:(UITapGestureRecognizer *)recognizer {
    zhFullView *_self = self;
    [self endAnimationsCompletion:^(zhFullView *fullView) {
        if (nil != self.didClickFullView) {
            _self.didClickFullView((zhFullView *)recognizer.view);
        }
    }];
}

- (void)itemClicked:(UITapGestureRecognizer *)recognizer  {
    if (nil != self.didClickItems) {
        self.didClickItems(self, recognizer.view.tag);
    }
}

- (void)closeClicked:(UIButton *)sender {
    [_scrollContainer setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x /[UIScreen width] + 0.5;
    _closeButton.userInteractionEnabled = index > 0;
    [_closeIcon setImage:[UIImage imageNamed:@"popup_close_btn"] forState:UIControlStateNormal];
}

- (void)startAnimationsCompletion:(void (^ __nullable)(BOOL finished))completion {

    [UIView animateWithDuration:0.5 animations:^{
        _closeIcon.transform = CGAffineTransformMakeRotation(M_PI_4);
    } completion:NULL];

    [_items enumerateObjectsUsingBlock:^(zhIconLabel *item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.alpha = 0;
        item.transform = CGAffineTransformMakeTranslation(0, self.rows * _itemSize.height);
        [UIView animateWithDuration:0.85
                              delay:idx * 0.035
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             item.alpha = 1;
                             item.transform = CGAffineTransformIdentity;
                         } completion:completion];
    }];
}

- (void)endAnimationsCompletion:(void (^)(zhFullView *))completion {
    if (!_closeButton.userInteractionEnabled) {
        [UIView animateWithDuration:0.35 animations:^{
            _closeIcon.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }

    [_items enumerateObjectsUsingBlock:^(zhIconLabel * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:0.25
                              delay:0.02f * (_items.count - idx)
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{

                             item.alpha = 0;
                             item.transform = CGAffineTransformMakeTranslation(0, self.rows * _itemSize.height);
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 if (idx == _items.count - 1) {
                                     completion(self);
                                 }
                             }
                         }];
    }];
}

@end
