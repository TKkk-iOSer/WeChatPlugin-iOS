//
//  zhPopupController.m
//  <https://github.com/snail-z/zhPopupController.git>
//
//  Created by zhanghao on 2016/11/15.
//  Copyright © 2017年 snail-z. All rights reserved.
//

#import "zhPopupController.h"
#import <objc/runtime.h>

@interface zhPopupController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) UIView *superview;
@property (nonatomic, strong, readonly) UIView *maskView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, assign, readonly) CGFloat dropAngle;
@property (nonatomic, assign, readonly) CGPoint markerCenter;
@property (nonatomic, assign, readonly) zhPopupMaskType maskType;

@end

static void *zhPopupControllerParametersKey = &zhPopupControllerParametersKey;
static void *zhPopupControllerNSTimerKey = &zhPopupControllerNSTimerKey;

@implementation zhPopupController

+ (instancetype)popupControllerWithMaskType:(zhPopupMaskType)maskType {
    return [[self alloc] initWithMaskType:maskType];
}

- (instancetype)init {
    return [self initWithMaskType:zhPopupMaskTypeBlackTranslucent];
}

- (instancetype)initWithMaskType:(zhPopupMaskType)maskType {
    if (self = [super init]) {
        _isPresenting = NO;
        _maskType = maskType;
        _layoutType = zhPopupLayoutTypeCenter;
        _dismissOnMaskTouched = YES;

        // setter
        self.maskAlpha = 0.5f;
        self.slideStyle = zhPopupSlideStyleFade;
        self.dismissOppositeDirection = NO;
        self.allowPan = NO;

        // superview
        _superview = [self frontWindow];

        // maskView
        if (maskType == zhPopupMaskTypeBlackBlur || maskType == zhPopupMaskTypeWhiteBlur) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
            _maskView = [[UIView alloc] initWithFrame:_superview.bounds];
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] init];
            visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            visualEffectView.frame = _superview.bounds;
            [_maskView insertSubview:visualEffectView atIndex:0];
#else
            _maskView = [[UIToolbar alloc] initWithFrame:_superview.bounds];
#endif
        } else {
            _maskView = [[UIView alloc] initWithFrame:_superview.bounds];
        }

        switch (maskType) {
            case zhPopupMaskTypeBlackBlur: {
                if ([_maskView isKindOfClass:[UIToolbar class]]) {
                     [(UIToolbar *)_maskView setBarStyle:UIBarStyleBlack];
                } else {
                    UIVisualEffectView *effectView = (UIVisualEffectView *)_maskView.subviews.firstObject;
                    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                }
            } break;
            case zhPopupMaskTypeWhiteBlur: {
                if ([_maskView isKindOfClass:[UIToolbar class]]) {
                    [(UIToolbar *)_maskView setBarStyle:UIBarStyleDefault];
                } else {
                    UIVisualEffectView *effectView = (UIVisualEffectView *)_maskView.subviews.firstObject;
                    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                }
            } break;
            case zhPopupMaskTypeWhite:
                _maskView.backgroundColor = [UIColor whiteColor];
                break;
            case zhPopupMaskTypeClear:
                _maskView.backgroundColor = [UIColor clearColor];
                break;
            default: // zhPopupMaskTypeBlackTranslucent
                _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
                break;
        }

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTap:)];
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];

        // popupView
        _popupView = [[UIView alloc] init];
        _popupView.backgroundColor = [UIColor clearColor];

        // addSubview
        [_maskView addSubview:_popupView];
        [_superview addSubview:_maskView];

        // Observer statusBar orientation changes.
        [self bindNotificationEvent];
    }
    return self;
}

#pragma mark - Setter

- (void)setDismissOppositeDirection:(BOOL)dismissOppositeDirection {
    _dismissOppositeDirection = dismissOppositeDirection;
    objc_setAssociatedObject(self, _cmd, @(dismissOppositeDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setSlideStyle:(zhPopupSlideStyle)slideStyle {
    _slideStyle = slideStyle;
    objc_setAssociatedObject(self, _cmd, @(slideStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    if (_maskType != zhPopupMaskTypeBlackTranslucent) return;
    _maskAlpha = maskAlpha;
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
}

- (void)setAllowPan:(BOOL)allowPan {
    if (!allowPan) return;
    if (_allowPan != allowPan) {
        _allowPan = allowPan;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_popupView addGestureRecognizer:pan];
    }
}

#pragma mark - Present

- (void)presentContentView:(UIView *)contentView {
    [self presentContentView:contentView duration:0.25 springAnimated:NO];
}

- (void)presentContentView:(UIView *)contentView displayTime:(NSTimeInterval)displayTime {
    [self presentContentView:contentView duration:0.25 springAnimated:NO inView:nil displayTime:displayTime];
}

- (void)presentContentView:(UIView *)contentView duration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated {
    [self presentContentView:contentView duration:duration springAnimated:isSpringAnimated inView:nil];
}

- (void)presentContentView:(UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(UIView *)sView {
    [self presentContentView:contentView duration:duration springAnimated:isSpringAnimated inView:sView displayTime:0];
}

- (void)presentContentView:(UIView *)contentView
                  duration:(NSTimeInterval)duration
            springAnimated:(BOOL)isSpringAnimated
                    inView:(UIView *)sView
               displayTime:(NSTimeInterval)displayTime {

    if (self.isPresenting) return;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:@(duration) forKey:@"zh_duration"];
    [parameters setValue:@(isSpringAnimated) forKey:@"zh_springAnimated"];
    objc_setAssociatedObject(self, zhPopupControllerParametersKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (nil != self.willPresent) {
        self.willPresent(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
            [self.delegate popupControllerWillPresent:self];
        }
    }

    if (nil != sView) {
        _superview = sView;
        _maskView.frame = _superview.frame;
    }
    [self addContentView:contentView];
    if (![_superview.subviews containsObject:_maskView]) {
        [_superview addSubview:_maskView];
    }

    [self prepareDropAnimated];
    [self prepareBackground];
    _popupView.userInteractionEnabled = NO;
    _popupView.center = [self prepareCenter];

    void (^presentCompletion)(void) = ^() {
        _isPresenting = YES;
        _popupView.userInteractionEnabled = YES;
        if (nil != self.didPresent) {
            self.didPresent(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                [self.delegate popupControllerDidPresent:self];
            }
        }

        if (displayTime) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:displayTime target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            objc_setAssociatedObject(self, zhPopupControllerNSTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    };

    if (isSpringAnimated) {
        [UIView animateWithDuration:duration delay:0.f usingSpringWithDamping:0.6 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveLinear animations:^{

            [self finishedDropAnimated];
            [self finishedBackground];
            _popupView.center = [self finishedCenter];

        } completion:^(BOOL finished) {

            if (finished) presentCompletion();

        }];
    } else {
        [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{

            [self finishedDropAnimated];
            [self finishedBackground];
            _popupView.center = [self finishedCenter];

        } completion:^(BOOL finished) {

            if (finished) presentCompletion();

        }];
    }
}

#pragma mark - Dismiss

- (void)dismiss {
    id object = objc_getAssociatedObject(self, zhPopupControllerParametersKey);
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        NSTimeInterval duration = 0.0;
        NSNumber *durationNumber = [object valueForKey:@"zh_duration"];
        if (nil != durationNumber) duration = durationNumber.doubleValue;
        BOOL flag = NO;
        NSNumber *flagNumber = [object valueForKey:@"zh_springAnimated"];
        if (nil != flagNumber) flag = flagNumber.boolValue;
        [self dismissWithDuration:duration springAnimated:flag];
    }
}

- (void)dismissWithDuration:(NSTimeInterval)duration springAnimated:(BOOL)isSpringAnimated {
    [self destroyTimer];

    if (!self.isPresenting) return;

    if (nil != self.willDismiss) {
        self.willDismiss(self);
    } else {
        if ([self.delegate respondsToSelector:@selector(popupControllerWillDismiss:)]) {
            [self.delegate popupControllerWillDismiss:self];
        }
    }

    void (^dismissCompletion)(void) = ^() {
        [self removeSubviews];
        _isPresenting = NO;
        _popupView.transform = CGAffineTransformIdentity;
        if (nil != self.didDismiss) {
            self.didDismiss(self);
        } else {
            if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                [self.delegate popupControllerDidDismiss:self];
            }
        }
    };

    UIViewAnimationOptions (^animOpts)(zhPopupSlideStyle) = ^(zhPopupSlideStyle slide){
        if (slide != zhPopupSlideStyleShrinkInOut) {
            return UIViewAnimationOptionCurveLinear;
        }
        return UIViewAnimationOptionCurveEaseInOut;
    };

    if (isSpringAnimated) {
        duration *= 0.75;
        NSTimeInterval duration1 = duration * 0.25, duration2 = duration - duration1;

        [UIView animateWithDuration:duration1 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{

            [self bufferBackground];
            _popupView.center = [self bufferCenter:30];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration2 delay:0.f options:animOpts(self.slideStyle) animations:^{

                [self dismissedDropAnimated];
                [self dismissedBackground];
                _popupView.center = [self dismissedCenter];

            } completion:^(BOOL finished) {
                if (finished) dismissCompletion();
            }];

        }];

    } else {
        [UIView animateWithDuration:duration delay:0.f options:animOpts(self.slideStyle) animations:^{

            [self dismissedDropAnimated];
            [self dismissedBackground];
            _popupView.center = [self dismissedCenter];

        } completion:^(BOOL finished) {
            if (finished) dismissCompletion();
        }];
    }
}

#pragma mark - Add contentView

- (void)addContentView:(UIView *)contentView {
    if (!contentView) {
        if (nil != _popupView.superview) [_popupView removeFromSuperview];
        return;
    }
    _contentView = contentView;
    if (_contentView.superview != _popupView) {
        _contentView.frame = (CGRect){.origin = CGPointZero, .size = contentView.frame.size};
        _popupView.frame = _contentView.frame;
        _popupView.backgroundColor = _contentView.backgroundColor;
        if (_contentView.layer.cornerRadius) {
            _popupView.layer.cornerRadius = _contentView.layer.cornerRadius;
            _popupView.clipsToBounds = NO;
        }
        [_popupView addSubview:_contentView];
    }
}

- (void)removeSubviews {
    if (_popupView.subviews.count > 0) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    [_maskView removeFromSuperview];
}

#pragma mark - Drop animated

- (void)dropAnimatedWithRotateAngle:(CGFloat)angle {
    _dropAngle = angle;
    _slideStyle = zhPopupSlideStyleFromTop;
}

- (BOOL)dropSupport {
    return (_layoutType == zhPopupLayoutTypeCenter && _slideStyle == zhPopupSlideStyleFromTop);
}

static CGFloat zh_randomValue(int i, int j) {
    if (arc4random() % 2) return i;
    return j;
}

- (void)prepareDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        _dismissOppositeDirection = YES;
        CGFloat ty = (_maskView.bounds.size.height + _popupView.frame.size.height) / 2;
        CATransform3D transform = CATransform3DMakeTranslation(0, -ty, 0);
        transform = CATransform3DRotate(transform,
                                        zh_randomValue(_dropAngle, -_dropAngle) * M_PI / 180,
                                        0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

- (void)finishedDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        _popupView.layer.transform = CATransform3DIdentity;
    }
}

- (void)dismissedDropAnimated {
    if (_dropAngle && [self dropSupport]) {
        CGFloat ty = _maskView.bounds.size.height;
        CATransform3D transform = CATransform3DMakeTranslation(0, ty, 0);
        transform = CATransform3DRotate(transform,
                                        zh_randomValue(_dropAngle, -_dropAngle) * M_PI / 180,
                                        0, 0, 1.0);
        _popupView.layer.transform = transform;
    }
}

#pragma mark - Mask view background

- (void)prepareBackground {
    switch (_maskType) {
        case zhPopupMaskTypeBlackBlur:
        case zhPopupMaskTypeWhiteBlur:
            _maskView.alpha = 1;
            break;
        default:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
            break;
    }
}

- (void)finishedBackground {
    switch (_maskType) {
        case zhPopupMaskTypeBlackTranslucent:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha];
            break;
        case zhPopupMaskTypeWhite:
            _maskView.backgroundColor = [UIColor whiteColor];
            break;
        case zhPopupMaskTypeClear:
            _maskView.backgroundColor = [UIColor clearColor];
            break;
        default: break;
    }
}

- (void)bufferBackground {
    switch (_maskType) {
        case zhPopupMaskTypeBlackBlur:
        case zhPopupMaskTypeWhiteBlur: break;
        case zhPopupMaskTypeBlackTranslucent:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:_maskAlpha - _maskAlpha * 0.15];
            break;
        default: break;
    }
}

- (void)dismissedBackground {
    switch (_maskType) {
        case zhPopupMaskTypeBlackBlur:
        case zhPopupMaskTypeWhiteBlur:
            _maskView.alpha = 0;
            break;
        default:
            _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
            break;
    }
}

#pragma mark - Center point

- (CGPoint)prepareCenterFrom:(NSInteger)type viewRef:(UIView *)viewRef{
    switch (type) {
        case 0: // top
            return CGPointMake(viewRef.center.x,
                               -_popupView.bounds.size.height / 2) ;
        case 1: // bottom
            return CGPointMake(viewRef.center.x,
                               _maskView.bounds.size.height + _popupView.bounds.size.height / 2);
        case 2: // left
            return CGPointMake(-_popupView.bounds.size.width / 2,
                               viewRef.center.y);
        case 3: // right
            return CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                               viewRef.center.y);
        default: // center
            return _maskView.center;
    }
}

- (CGPoint)prepareCenter {
    if (_layoutType == zhPopupLayoutTypeCenter) {
        CGPoint point = _maskView.center;
        if (_slideStyle == zhPopupSlideStyleShrinkInOut) {
            _popupView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } else if (_slideStyle == zhPopupSlideStyleFade) {
            _maskView.alpha = 0;
        } else {
            point = [self prepareCenterFrom:_slideStyle viewRef:_maskView];
        }
        return point;
    }
    return [self prepareCenterFrom:_layoutType viewRef:_maskView];
}

- (CGPoint)finishedCenter {
    CGPoint point = _maskView.center;
    switch (_layoutType) {
        case zhPopupLayoutTypeTop:
            return CGPointMake(point.x,
                               _popupView.bounds.size.height / 2);
        case zhPopupLayoutTypeBottom:
            return CGPointMake(point.x,
                               _maskView.bounds.size.height - _popupView.bounds.size.height / 2);
        case zhPopupLayoutTypeLeft:
            return CGPointMake(_popupView.bounds.size.width / 2,
                               point.y);
        case zhPopupLayoutTypeRight:
            return CGPointMake(_maskView.bounds.size.width - _popupView.bounds.size.width / 2,
                               point.y);
        default: // zhPopupLayoutTypeCenter
        {
            if (_slideStyle == zhPopupSlideStyleShrinkInOut) {
                _popupView.transform = CGAffineTransformIdentity;
            } else if (_slideStyle == zhPopupSlideStyleFade) {
                _maskView.alpha = 1;
            }
        }
        return point;
    }
}

- (CGPoint)dismissedCenter {
    if (_layoutType != zhPopupLayoutTypeCenter) {
        return [self prepareCenterFrom:_layoutType viewRef:_popupView];
    }
    switch (_slideStyle) {
        case zhPopupSlideStyleFromTop:
            return _dismissOppositeDirection ?
            CGPointMake(_popupView.center.x,
                        _maskView.bounds.size.height + _popupView.bounds.size.height / 2) :
            CGPointMake(_popupView.center.x,
                        -_popupView.bounds.size.height / 2);

        case zhPopupSlideStyleFromBottom:
            return _dismissOppositeDirection ?
            CGPointMake(_popupView.center.x,
                        -_popupView.bounds.size.height / 2) :
            CGPointMake(_popupView.center.x,
                        _maskView.bounds.size.height + _popupView.bounds.size.height / 2);

        case zhPopupSlideStyleFromLeft:
            return _dismissOppositeDirection ?
            CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                        _popupView.center.y) :
            CGPointMake(-_popupView.bounds.size.width / 2,
                        _popupView.center.y);

        case zhPopupSlideStyleFromRight:
            return _dismissOppositeDirection ?
            CGPointMake(-_popupView.bounds.size.width / 2,
                        _popupView.center.y) :
            CGPointMake(_maskView.bounds.size.width + _popupView.bounds.size.width / 2,
                        _popupView.center.y);

        case zhPopupSlideStyleShrinkInOut:
            _popupView.transform = _dismissOppositeDirection ?
            CGAffineTransformMakeScale(1.95, 1.95) :
            CGAffineTransformMakeScale(0.05, 0.05);
            break;

        case zhPopupSlideStyleFade:
            _maskView.alpha = 0;
        default: break;
    }
    return _popupView.center;
}

#pragma mark - Buffer point

- (CGPoint)bufferCenter:(CGFloat)move {
    CGPoint point = _popupView.center;
    switch (_layoutType) {
        case zhPopupLayoutTypeTop:
            point.y += move;
            break;
        case zhPopupLayoutTypeBottom:
            point.y -= move;
            break;
        case zhPopupLayoutTypeLeft:
            point.x += move;
            break;
        case zhPopupLayoutTypeRight:
            point.x -= move;
            break;
        case zhPopupLayoutTypeCenter: {
            switch (_slideStyle) {
                case zhPopupSlideStyleFromTop:
                    point.y += _dismissOppositeDirection ? -move : move;
                    break;
                case zhPopupSlideStyleFromBottom:
                    point.y += _dismissOppositeDirection ? move : -move;
                    break;
                case zhPopupSlideStyleFromLeft:
                    point.x += _dismissOppositeDirection ? -move : move;
                    break;
                case zhPopupSlideStyleFromRight:
                    point.x += _dismissOppositeDirection ? move : -move;
                    break;
                case zhPopupSlideStyleShrinkInOut:
                    _popupView.transform = _dismissOppositeDirection ?
                    CGAffineTransformMakeScale(0.95, 0.95) :
                    CGAffineTransformMakeScale(1.05, 1.05);
                    break;
                default: break;
            }
        } break;
        default: break;
    }
    return point;
}

#pragma mark - Destroy timer

- (void)destroyTimer {
    id value = objc_getAssociatedObject(self, zhPopupControllerNSTimerKey);
    if (value) {
        [(NSTimer *)value invalidate];
        objc_setAssociatedObject(self, zhPopupControllerNSTimerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - FrontWindow

- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;

        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    NSLog(@" ** zhPopupController ** Window is nil!");
    return nil;
}

#pragma mark - Notifications

- (void)bindNotificationEvent {
    [self unbindNotificationEvent];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willChangeStatusBarOrientation)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)unbindNotificationEvent {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationWillChangeStatusBarOrientationNotification
                                                 object:nil];

    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidChangeStatusBarOrientationNotification
                                                 object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

#pragma mark - Observing

- (void)keyboardWillChangeFrame:(NSNotification*)notification {

    _allowPan = NO; // The pan gesture will be invalid when the keyboard appears.

    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [_maskView convertRect:keyboardRect fromView:nil];
    CGFloat keyboardHeight = CGRectGetHeight(_maskView.bounds) - CGRectGetMinY(keyboardRect);

    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = curve << 16;

    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        if (keyboardHeight > 0) {

            CGFloat offsetSpacing = self.offsetSpacingOfKeyboard, changeHeight = 0;

            switch (_layoutType) {
                case zhPopupLayoutTypeTop:
                    break;
                case zhPopupLayoutTypeBottom:
                    changeHeight = keyboardHeight + offsetSpacing;
                    break;
                default:
                    changeHeight = (keyboardHeight / 2) + offsetSpacing;
                    break;
            }

            if (!CGPointEqualToPoint(CGPointZero, _markerCenter)) {
                _popupView.center = CGPointMake(_markerCenter.x, _markerCenter.y - changeHeight);
            } else {
                _popupView.center = CGPointMake(_popupView.center.x, _popupView.center.y - changeHeight);
            }

        } else {
            if (self.isPresenting) {
                _popupView.center = [self finishedCenter];
            }
        }
    } completion:^(BOOL finished) {
        _markerCenter = [self finishedCenter];
    }];
}

- (void)willChangeStatusBarOrientation {
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenter];
    [self dismiss];
}

- (void)didChangeStatusBarOrientation {
    if ([[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) { // must manually fix orientation prior to iOS 8
        CGFloat angle;
        switch ([UIApplication sharedApplication].statusBarOrientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = -M_PI_2;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI_2;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                break;
        }
        _popupView.transform = CGAffineTransformMakeRotation(angle);
    }
    _maskView.frame = _superview.bounds;
    _popupView.center = [self finishedCenter];
}

#pragma mark - Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_popupView]) return NO;
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)g {
    if (_dismissOnMaskTouched) {
        if (!_dropAngle) {
            id object = objc_getAssociatedObject(self, @selector(setSlideStyle:));
            _slideStyle = [object integerValue];
            id obj = objc_getAssociatedObject(self, @selector(setDismissOppositeDirection:));
            _dismissOppositeDirection = [obj boolValue];
        }
        if (nil != self.maskTouched) {
            self.maskTouched(self);
        } else {
            [self dismiss];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    if (!_allowPan || !_isPresenting || _dropAngle) {
        return;
    }
    CGPoint translation = [g translationInView:_maskView];
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_layoutType) {
                case zhPopupLayoutTypeCenter: {

                    BOOL isTransformationVertical = NO;
                    switch (_slideStyle) {
                        case zhPopupSlideStyleFromLeft:
                        case zhPopupSlideStyleFromRight: break;
                        default:
                            isTransformationVertical = YES;
                            break;
                    }

                    NSInteger factor = 4; // set screen ratio `_maskView.bounds.size.height / factor`
                    CGFloat changeValue;
                    if (isTransformationVertical) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                        changeValue = g.view.center.y / (_maskView.bounds.size.height / factor);
                    } else {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                        changeValue = g.view.center.x / (_maskView.bounds.size.width / factor);
                    }
                    CGFloat alpha = factor / 2 - fabs(changeValue - factor / 2);
                    [UIView animateWithDuration:0.15 animations:^{
                        _maskView.alpha = alpha;
                    } completion:NULL];

                } break;
                case zhPopupLayoutTypeBottom: {
                    if (g.view.frame.origin.y + translation.y > _maskView.bounds.size.height - g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case zhPopupLayoutTypeTop: {
                    if (g.view.frame.origin.y + g.view.frame.size.height + translation.y  < g.view.bounds.size.height) {
                        g.view.center = CGPointMake(g.view.center.x, g.view.center.y + translation.y);
                    }
                } break;
                case zhPopupLayoutTypeLeft: {
                    if (g.view.frame.origin.x + g.view.frame.size.width + translation.x < g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                case zhPopupLayoutTypeRight: {
                    if (g.view.frame.origin.x + translation.x > _maskView.bounds.size.width - g.view.bounds.size.width) {
                        g.view.center = CGPointMake(g.view.center.x + translation.x, g.view.center.y);
                    }
                } break;
                default: break;
            }
            [g setTranslation:CGPointZero inView:_maskView];
        } break;
        case UIGestureRecognizerStateEnded: {

            BOOL isWillDismiss = YES, isStyleCentered = NO;
            switch (_layoutType) {
                case zhPopupLayoutTypeCenter: {
                    isStyleCentered = YES;
                    if (g.view.center.y != _maskView.center.y) {
                        if (g.view.center.y > _maskView.bounds.size.height * 0.25 &&
                            g.view.center.y < _maskView.bounds.size.height * 0.75) {
                            isWillDismiss = NO;
                        }
                    } else {
                        if (g.view.center.x > _maskView.bounds.size.width * 0.25 &&
                            g.view.center.x < _maskView.bounds.size.width * 0.75) {
                            isWillDismiss = NO;
                        }
                    }
                } break;
                case zhPopupLayoutTypeBottom:
                    isWillDismiss = g.view.frame.origin.y > _maskView.bounds.size.height - g.view.frame.size.height * 0.75;
                    break;
                case zhPopupLayoutTypeTop:
                    isWillDismiss = g.view.frame.origin.y + g.view.frame.size.height < g.view.frame.size.height * 0.75;
                    break;
                case zhPopupLayoutTypeLeft:
                    isWillDismiss = g.view.frame.origin.x + g.view.frame.size.width < g.view.frame.size.width * 0.75;
                    break;
                case zhPopupLayoutTypeRight:
                    isWillDismiss = g.view.frame.origin.x > _maskView.bounds.size.width - g.view.frame.size.width * 0.75;
                    break;
                default: break;
            }
            if (isWillDismiss) {
                if (isStyleCentered) {
                    switch (_slideStyle) {
                        case zhPopupSlideStyleShrinkInOut:
                        case zhPopupSlideStyleFade: {
                            if (g.view.center.y < _maskView.bounds.size.height * 0.25) {
                                _slideStyle = zhPopupSlideStyleFromTop;
                            } else {
                                if (g.view.center.y > _maskView.bounds.size.height * 0.75) {
                                    _slideStyle = zhPopupSlideStyleFromBottom;
                                }
                            }
                            _dismissOppositeDirection = NO;
                        } break;
                        case zhPopupSlideStyleFromTop:
                            _dismissOppositeDirection = !(g.view.center.y < _maskView.bounds.size.height * 0.25);
                            break;
                        case zhPopupSlideStyleFromBottom:
                            _dismissOppositeDirection = g.view.center.y < _maskView.bounds.size.height * 0.25;
                            break;
                        case zhPopupSlideStyleFromLeft:
                            _dismissOppositeDirection = !(g.view.center.x < _maskView.bounds.size.width * 0.25);
                            break;
                        case zhPopupSlideStyleFromRight:
                            _dismissOppositeDirection = g.view.center.x < _maskView.bounds.size.width * 0.25;
                            break;
                        default: break;
                    }
                }

                [self dismissWithDuration:0.25f springAnimated:NO];

            } else {
                // restore view location.
                id object = objc_getAssociatedObject(self, zhPopupControllerParametersKey);
                NSNumber *flagNumber = [object valueForKey:@"zh_springAnimated"];
                BOOL flag = NO;
                if (nil != flagNumber) {
                    flag = flagNumber.boolValue;
                }
                NSTimeInterval duration = 0.25;
                NSNumber* durationNumber = [object valueForKey:@"zh_duration"];
                if (nil != durationNumber) {
                    duration = durationNumber.doubleValue;
                }
                if (flag) {
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                        g.view.center = [self finishedCenter];
                    } completion:NULL];
                } else {
                    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        g.view.center = [self finishedCenter];
                    } completion:NULL];
                }
            }

        } break;
        case UIGestureRecognizerStateCancelled:
            break;
        default: break;
    }
}

- (void)dealloc {
  [super dealloc];
    [self unbindNotificationEvent];
    [self removeSubviews];
}

@end

@implementation NSObject (zhPopupController)

- (zhPopupController *)zh_popupController {
    id popupController = objc_getAssociatedObject(self, _cmd);
    if (nil == popupController) {
        popupController = [[zhPopupController alloc] init];
        self.zh_popupController = popupController;
    }
    return popupController;
}

- (void)setZh_popupController:(zhPopupController *)zh_popupController {
    objc_setAssociatedObject(self, @selector(zh_popupController), zh_popupController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
