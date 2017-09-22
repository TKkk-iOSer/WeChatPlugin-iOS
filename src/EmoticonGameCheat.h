//
//  EmoticonGameCheat.h
//
//  Created by lanjuzi on 2017/9/22.
//  Copyright © 2017年 lanjuzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zhPopupController.h"
#import "zhFullView.h"
#import "zhIconLabel.h"

@interface EmoticonGameCheat : NSObject

+ (void)showEoticonCheat:(NSInteger)uiGameType callback:(void (^)(NSInteger random))callback;

@end

