//
//  zhPopupController.h
//  <https://github.com/snail-z/zhPopupController.git>
//
//  Created by zhanghao on 2016/11/15.
//  Copyright © 2017年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Control mask view of type.
typedef NS_ENUM(NSUInteger, zhPopupMaskType) {
    zhPopupMaskTypeBlackBlur = 0,
    zhPopupMaskTypeWhiteBlur,
    zhPopupMaskTypeWhite,
    zhPopupMaskTypeClear,
    zhPopupMaskTypeBlackTranslucent // default
};

// Control content View shows of layout type, when end of the animation.
typedef NS_ENUM(NSUInteger, zhPopupLayoutType) {
    zhPopupLayoutTypeTop = 0,
    zhPopupLayoutTypeBottom,
    zhPopupLayoutTypeLeft,
    zhPopupLayoutTypeRight,
    zhPopupLayoutTypeCenter // default
};

// Control content view from a direction sliding out of style.
typedef NS_ENUM(NSInteger, zhPopupSlideStyle) {
    zhPopupSlideStyleFromTop = 0,
    zhPopupSlideStyleFromBottom,
    zhPopupSlideStyleFromLeft,
    zhPopupSlideStyleFromRight,
    zhPopupSlideStyleShrinkInOut,
    zhPopupSlideStyleFade // default
};

@protocol zhPopupControllerDelegate;

@interface zhPopupController : NSObject

@property (nonatomic, strong) id <zhPopupControllerDelegate> delegate;

/// Convenient to initialize and set maske type. (Through the `- init` initialization, maskType is zhPopupMaskTypeBlackTranslucent)
+ (instancetype)popupControllerWithMaskType:(zhPopupMaskType)maskType;

/// The `popupView` is the parent view of your custom contentView
@property (nonatomic, strong, readonly) UIView *popupView;

/// Whether contentView is presenting.
@property (nonatomic, assign, readonly) BOOL isPresenting;

/// Set popup view display position. default is zhPopupLayoutTypeCenter
@property (nonatomic, assign) zhPopupLayoutType layoutType;

/// Set popup view slide Style. default is zhPopupSlideStyleFade
@property (nonatomic, assign) zhPopupSlideStyle slideStyle; // When `layoutType = zhPopupLayoutTypeCenter` is vaild.

/// set mask view of transparency, default is 0.5
@property (nonatomic, assign) CGFloat maskAlpha; // When set maskType is zhPopupMaskTypeBlackTranslucent vaild.

/// default is YES. if NO, Mask view will not respond to events.
@property (nonatomic, assign) BOOL dismissOnMaskTouched;

/// default is NO. if YES, Popup view disappear from the opposite direction.
@property (nonatomic, assign) BOOL dismissOppositeDirection; // When `layoutType = zhPopupLayoutTypeCenter` is vaild.

/// Content view whether to allow drag, default is NO
@property (nonatomic, assign) BOOL allowPan; // 1.The view will support dragging when popup view of position is at the center of the screen or at the edge of the screen. 2.The pan gesture will be invalid when the keyboard appears.

/// You can adjust the spacing relative to the keyboard when the keyboard appears. default is 0
@property (nonatomic, assign) CGFloat offsetSpacingOfKeyboard;

/// Use drop animation and set the rotation Angle. if set, Will not support drag.
- (void)dropAnimatedWithRotateAngle:(CGFloat)angle;

/// Block gets called when mask touched.
@property (nonatomic, copy) void (^maskTouched)(zhPopupController *popupController);

/// - Should implement this block before the presenting. 应在present前实现的block ☟
/// Block gets called when contentView will present.
@property (nonatomic, copy) void (^willPresent)(zhPopupController *popupController);

/// Block gets called when contentView did present.
@property (nonatomic, copy) void (^didPresent)(zhPopupController *popupController);

/// Block gets called when contentView will dismiss.
@property (nonatomic, copy) void (^willDismiss)(zhPopupController *popupController);

/// Block gets called when contentView did dismiss.
@property (nonatomic, copy) void (^didDismiss)(zhPopupController *popupController);

/**
 present your content view.
 @param contentView This is the view that you want to appear in popup. / 弹出自定义的contentView
 @param duration Popup animation time. / 弹出动画时长
 @param isSpringAnimated if YES, Will use a spring animation. / 是否使用弹性动画
 @param sView  Displayed on the sView. if nil, Displayed on the window. / 显示在sView上
 @param displayTime The view will disappear after `displayTime` seconds. / 视图将在displayTime后消失
 */
- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(nullable UIView *)sView
               displayTime:(NSTimeInterval)displayTime;

- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(nullable UIView *)sView;

- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated;

- (void)presentContentView:(nullable UIView *)contentView displayTime:(NSTimeInterval)displayTime;;

- (void)presentContentView:(nullable UIView *)contentView; // duration is 0.25 / springAnimated is NO / show in window

/// dismiss your content view.
- (void)dismissWithDuration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated;

- (void)dismiss; // Will use the present parameter values.

@end

@protocol zhPopupControllerDelegate <NSObject>
@optional
// - The Delegate method, block is preferred.
- (void)popupControllerWillPresent:(nonnull zhPopupController *)popupController;
- (void)popupControllerDidPresent:(nonnull zhPopupController *)popupController;
- (void)popupControllerWillDismiss:(nonnull zhPopupController *)popupController;
- (void)popupControllerDidDismiss:(nonnull zhPopupController *)popupController;

@end

@interface NSObject (zhPopupController)

@property (nonatomic, strong) zhPopupController *zh_popupController; // Suggested that direct use of zh_popupController.

@end

NS_ASSUME_NONNULL_END
