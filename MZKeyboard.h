//
//  MZKeyboard.h
//  MZKeyboard
//
//  Created by GuYi on 16/10/12.
//  Copyright © 2016年 aicai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MZKeyboardType) {
    MZKeyboardNumberWithShift = 0,    //数字键盘可切换
    MZKeyboardNumberWithoutShift,     //数字键盘不可切换
    MZKeyboardNumberBuy,              //购买数字键盘
    MZKeyboardAlphabet,               //英文键盘
    MZKeyboardSymbol,                 //符号键盘
};


typedef NS_ENUM(NSUInteger, MZKeyboardClickButtonType) {
    DoneButton = 0,
    DeleteButton,
};

@protocol MZKeyboardDelegate <NSObject>

- (void)keyboardClickOnButtonType:(MZKeyboardClickButtonType)type;

@end

@interface MZKeyboard : UIView

@property(nonatomic,weak)id<MZKeyboardDelegate> delegate;

@property(nonatomic,strong)UIButton *hideButton; //安全解盘上方关闭键盘按钮

/**
 创建键盘

 @param inputSource 输入源，如UITextfield...
 @param type 键盘类型
 @param feature 是否显示安全键盘图标
 @param delegate

 @return 键盘实例
 */

- (id)createKeyboardByInputSource:(UIView*)inputSource withType:(MZKeyboardType)type isShowFeature:(BOOL)feature delegate:(id<MZKeyboardDelegate>)delegate;




@end
