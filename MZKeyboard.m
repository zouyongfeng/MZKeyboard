//
//  MZKeyboard.m
//  MZKeyboard
//
//  Created by GuYi on 16/10/12.
//  Copyright © 2016年 aicai. All rights reserved.
//

#import "MZKeyboard.h"

@interface UIImage (MZKeyboard)

+ (UIImage *)mz_imageFromColor:(UIColor *)color;

- (UIImage *)mz_drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size;

@end

@implementation UIImage (MZKeyboard)

+ (UIImage *)mz_imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)mz_drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size {
    CGRect bounds = CGRectZero;
    bounds.size = size;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    [self drawInRect:bounds];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

@end

typedef NS_ENUM(NSUInteger, MZKeyboardButtonType) {
    MZNumberKeyboardButton = 0,
    MZNumberBuyKeyboardButton,
    MZAlphabetKeyboardButton,
};

@interface MZKeyboardButton : UIButton

- (instancetype)initWithButtonType:(MZKeyboardButtonType)type;

- (void)configButtonRoundCornerWithBackgroundColor:(UIColor*)color;

@end

@implementation MZKeyboardButton

- (instancetype)initWithButtonType:(MZKeyboardButtonType)type {
    self = [[MZKeyboardButton alloc]initWithFrame:CGRectZero];
    if (self) {
        switch (type) {
            case MZNumberBuyKeyboardButton:
                [self configMZKeyboardNumberBuyButton];
                break;
            case MZNumberKeyboardButton:
                [self configMZKeyboardNumberButton];
                break;
            default:
                [self configMZKeyboardAlphabetButton];
                break;
        }
    }
    return self;
}

//购买数字键盘按钮
- (void)configMZKeyboardNumberBuyButton {
    self.layer.borderWidth = 1 / kScreen_Scale / 2;
    self.layer.borderColor = UIColorFromRGB(0x8c8c8c).CGColor;
    self.titleLabel.font = [UIFont systemFontOfSize:25];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor whiteColor];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage mz_imageFromColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateHighlighted];
}

//普通数字键盘按钮
- (void)configMZKeyboardNumberButton {
    self.layer.borderWidth = 1 / kScreen_Scale / 2;
    self.layer.borderColor = UIColorFromRGB(0x8c8c8c).CGColor;
    self.titleLabel.font = [UIFont systemFontOfSize:25];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor whiteColor];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage mz_imageFromColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateHighlighted];
}

//英文符号键盘按钮
- (void)configMZKeyboardAlphabetButton {
    self.titleLabel.font = [UIFont systemFontOfSize:21];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage mz_imageFromColor:UIColorFromRGB(0xdddddd)] forState:UIControlStateHighlighted];

}

- (void)configButtonRoundCornerWithBackgroundColor:(UIColor *)color {
    
    CGSize size = [self bounds].size;
    UIImage *backImg = [UIImage mz_imageFromColor:color];
    backImg = [backImg mz_drawRectWithRoundCorner:4 toSize:size];
    [self setBackgroundImage:backImg forState:UIControlStateNormal];

}

@end

@interface MZKeyboard ()

@property(nonatomic,assign)MZKeyboardType type;
@property(nonatomic,assign)BOOL isShowFeature;
@property(nonatomic,weak)UIView *inputSource;

@property(nonatomic,assign)CGFloat keyboardHeight;

@property(nonatomic,assign)BOOL isUpper;
@property(nonatomic,strong)NSArray *upperArray;
@property(nonatomic,strong)NSArray *noupperArray;

@end

@implementation MZKeyboard

- (instancetype)createKeyboardByInputSource:(UIView*)inputSource withType:(MZKeyboardType)type isShowFeature:(BOOL)feature delegate:(id<MZKeyboardDelegate>)delegate{
    
    return [[MZKeyboard alloc]initWithInputSource:inputSource withType:type isShowFeature:feature delegate:delegate];
    
}

- (instancetype)initWithInputSource:(UIView *)inputSource withType:(MZKeyboardType)type isShowFeature:(BOOL)isShowFeature delegate:(id<MZKeyboardDelegate>)delegate{
    
    switch (type) {
        case MZKeyboardNumberBuy:self.keyboardHeight = isShowFeature ? 256 : 216; break;
        case MZKeyboardNumberWithShift:self.keyboardHeight = isShowFeature ? 256 : 216; break;
        case MZKeyboardNumberWithoutShift:self.keyboardHeight = isShowFeature ? 256 : 216; break;
        case MZKeyboardSymbol:self.keyboardHeight = isShowFeature ? 255 : 215; break;
        case MZKeyboardAlphabet:self.keyboardHeight = isShowFeature ? 308 : 268; break;
    }
    CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.keyboardHeight, [UIScreen mainScreen].bounds.size.width, self.keyboardHeight);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.isShowFeature = isShowFeature;
        self.inputSource = inputSource;
        self.delegate = delegate;
        [self setupFeatureHead];
        [self setupKeyBoard];
    }
    return self;
}

//配置键盘上方视图
- (void)setupFeatureHead {
    if (self.isShowFeature) {
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
        headView.backgroundColor = UIColorFromRGB(0xdddddd);
        if(self.type == MZKeyboardNumberBuy) {
            headView.backgroundColor = [UIColor whiteColor];
        }
        UIView *topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1 / kScreen_Scale)];
        topLineView.backgroundColor = UIColorFromRGB(0x8c8c8c);
        [headView addSubview:topLineView];
        UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, kScreenW, 1 / kScreen_Scale / 2)];
        bottomLineView.backgroundColor = UIColorFromRGB(0x8c8c8c);
        if (self.type == MZKeyboardAlphabet || self.type == MZKeyboardSymbol) {
            bottomLineView.height = 1 / kScreen_Scale;
        }
        [headView addSubview:bottomLineView];
        self.hideButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenW-60, 0, 60, 40)];
        self.hideButton.contentMode = UIViewContentModeCenter;
        [self.hideButton setImage:[UIImage imageNamed:@"keyboard_hide"] forState:UIControlStateNormal];
        [self.hideButton addTarget:self action:@selector(hideKeyboardAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:self.hideButton];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
        [titleLabel setCenterX:headView.centerX + 11];
        [titleLabel setCenterY:headView.centerY];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.tintColor = UIColorFromRGB(0x333333);
        titleLabel.text = @"米庄理财安全键盘";
        [headView addSubview:titleLabel];
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x - 15, 12.5, 11, 15)];
        icon.image = [UIImage imageNamed:@"keyboard_lock"];
        [headView addSubview:icon];
        [self addSubview:headView];
    }
}

//配置键盘
- (void)setupKeyBoard {
    
    switch (self.type) {
        case MZKeyboardNumberWithShift:
            [self loadMZKeyboardNumberCanShift:YES];
            break;
        case MZKeyboardNumberWithoutShift:
            [self loadMZKeyboardNumberCanShift:NO];
            break;
        case MZKeyboardNumberBuy:
            [self loadMZKeyboardNumberBuy];
            break;
        case MZKeyboardAlphabet:
            [self loadMZKeyboardAlphabet];
            break;
        case MZKeyboardSymbol:
            [self loadMZKeyboardSymbol];
            break;
    }
}

#pragma mark- 键盘布局
//普通数字键盘
- (void)loadMZKeyboardNumberCanShift:(BOOL)canShift {
    
    int column = 3;
    int row = 4;
    CGFloat itemH = 54;
    CGFloat itemW = self.frame.size.width/column;
    CGFloat headH = self.isShowFeature ? 40 : 0;
    NSArray *caple = @[@[@"1",@"2",@"3"],@[@"4",@"5",@"6"],@[@"7",@"8",@"9"],@[@"",@"0",@""]];
    
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < column; j++) {
            MZKeyboardButton *button = [[MZKeyboardButton alloc]initWithButtonType:MZNumberKeyboardButton];
            CGRect frame = CGRectMake(j*itemW, i*itemH+headH, itemW, itemH);
            button.frame = frame;
            if (i ==3 && j == 2) {
                [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                [button setImage:[UIImage imageNamed:@"keyboard_cancel"] forState:UIControlStateNormal];
                [button setBackgroundColor:UIColorFromRGB(0xdddddd)];
            }
            else if(i == 3 && j == 0){
                if (canShift) {
                    [button setTitle:@"ABC" forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(shiftToAlphabetKeyboardAction:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else {
                [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:(NSString*)caple[i][j] forState:UIControlStateNormal];
            }
            if (button) {
                [self addSubview:button];
            }
        }
    }

}
//购买数字键盘
- (void)loadMZKeyboardNumberBuy {
    
    int column = 4;
    int row = 4;
    CGFloat itemH = 54;
    CGFloat itemW = self.frame.size.width/column;
    CGFloat headH = self.isShowFeature ? 40 : 0;
    NSArray *caple = @[@[@"1",@"2",@"3"],@[@"4",@"5",@"6"],@[@"7",@"8",@"9"],@[@".",@"0",@"00"]];
    
    for (int i = 0; i < row; i++) {
        for (int j = 0; j < column; j++) {
            MZKeyboardButton *button = [[MZKeyboardButton alloc]initWithButtonType:MZNumberBuyKeyboardButton];
            if (j != column-1) {
                CGRect frame = CGRectMake(j*itemW, i*itemH+headH, itemW, itemH);
                button.frame = frame;
                [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:(NSString*)caple[i][j] forState:UIControlStateNormal];
            }
            else if (j == column-1 && i !=0 && i != 2) {
                CGRect frame = CGRectMake(j*itemW, (i-1)*itemH+headH, itemW, itemH*2);
                button.frame = frame;
                if (i == 1) {
                    [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                    [button setImage:[UIImage imageNamed:@"keyboard_cancel"] forState:UIControlStateNormal];
                }
                else {
                    [button addTarget:self action:@selector(numberBuyKeyboardDoneAction:) forControlEvents:UIControlEventTouchUpInside];
                    [button setTitle:@"确定" forState:UIControlStateNormal];
                    [button setBackgroundColor:UIColorFromRGB(0xeeeeee)];
                }
            }
            else button = nil;
            if (button) {
                [self insertSubview:button atIndex:1];
            }
        }
    }
}

- (NSArray *)upperArray {
    if (!_upperArray) {
        _upperArray = @[@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"],@[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P"],@[@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L"],@[@"",@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@""],@[@"123",@"space",@"#+="]];
    }
    return _upperArray;
}

- (NSArray *)noupperArray {
    if (!_noupperArray) {
    _noupperArray = @[@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"],@[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p"],@[@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l"],@[@"",@"z",@"x",@"c",@"v",@"b",@"n",@"m",@""],@[@"123",@"space",@"#+="]];
    }
    return _noupperArray;
}
//英文键盘
- (void)loadMZKeyboardAlphabet {
    
    self.backgroundColor = UIColorFromRGB(0xdddddd);
    self.isUpper = NO;
    
    int row = 5;
    CGFloat itemH = 42;
    CGFloat itemW = 0;
    CGFloat headH = self.isShowFeature ? 40 : 0;

    for (int i = 0; i < row; i++) {
        NSArray *array = self.noupperArray[i];
        NSInteger column = array.count;
        CGFloat y = headH + 11 + (itemH + 11) * i;
        
        for (int j = 0; j < column; j++) {
            MZKeyboardButton *button = [[MZKeyboardButton alloc]initWithButtonType:MZAlphabetKeyboardButton];
            [button setTitle:self.noupperArray[i][j] forState:UIControlStateNormal];
            button.tag = 2000 + i * 100 + j;
            
            if (i == 0 || i == 1) {
                itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / column;
                CGRect frame = CGRectMake( 3 + j * (itemW + 6), y, itemW, itemH);
                button.frame = frame;
                [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (i == 2) {
                itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / 10;
                CGFloat x = (self.frame.size.width - column * itemW - (column - 1) * 6 ) / 2;
                CGRect frame = CGRectMake(x + j * (itemW + 6), y, itemW, itemH);
                button.frame = frame;
                [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (i == 3) {
                CGFloat shiftW = (self.frame.size.width - (column - 2) * (self.frame.size.width - 6 - 6 * (column - 1)) / 10 - (column - 3) * 6 ) / 2 - 3 - 6;
                if (j == 0 || j == column - 1) {
                    itemW = shiftW;
                    int isLast= j== 0 ? 0 : 1;
                    CGRect frame = CGRectMake(3 + isLast * (self.frame.size.width - itemW - 6), y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:UIColorFromRGB(0xabb3be)];
                    UIImage *image = j == column - 1 ? [UIImage imageNamed:@"keyboard_cancel"] : [UIImage imageNamed:@"keyboard_caps"];
                    [button setImage:image forState:UIControlStateNormal];
                    SEL action = j == column - 1 ? @selector(deleteAction:) : @selector(upperAction:);
                    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / 10;
                    CGRect frame = CGRectMake(shiftW +3 + 6 + (j - 1) * (itemW + 6), y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                    [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else {
                if (j == 0 || j == column -1) {
                    itemW = 85.5;
                    int isLast= j== 0 ? 0 : 1;
                    CGRect frame = CGRectMake(3 + isLast * (self.frame.size.width - itemW - 6), y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:UIColorFromRGB(0xabb3be)];
                    SEL action = j == 0 ? @selector(shiftToNumberKeyboardAction:) : @selector(shiftToSymbolKeyboardAction:);
                    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    itemW = self.frame.size.width - 6 - 2 * 85.5 - 12;
                    CGRect frame = CGRectMake(3 + 6 + 85.5, y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                    [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            [self addSubview:button];
        }
    }
}
//符号键盘
- (void)loadMZKeyboardSymbol {
    
    self.backgroundColor = UIColorFromRGB(0xdddddd);
    
    NSArray *symbolArray =@[@[@"!",@"@",@"#",@"$",@"%",@"^",@"&",@"*",@"(",@")"],@[@"'",@"\"",@"=",@"_",@":",@";",@"?",@"~",@"|",@"·"],@[@"+",@"-",@"\\",@"/",@"[",@"]",@"{",@"}",@""],@[@"123",@",",@".",@"<",@">",@"`",@"£",@"¥",@"ABC"]];
    int row = 4;
    CGFloat itemH = 42;
    CGFloat itemW = 0;
    CGFloat headH = self.isShowFeature ? 40 : 0;
    
    for (int i = 0; i < row; i++) {
        NSArray *array = symbolArray[i];
        NSInteger column = array.count;
        CGFloat y = headH + 11 + (itemH + 11) * i;
        
        for (int j = 0; j < column; j++) {
            MZKeyboardButton *button = [[MZKeyboardButton alloc]initWithButtonType:MZAlphabetKeyboardButton];
            [button setTitle:symbolArray[i][j] forState:UIControlStateNormal];
            
            if (i == 0 || i == 1) {
                itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / column;
                CGRect frame = CGRectMake( 3 + j * (itemW + 6), y, itemW, itemH);
                button.frame = frame;
                [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (i == 2) {
                itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / 10;
                CGFloat x = self.frame.size.width - (column - 1) * (itemW + 6) - 3 - 42;
                CGRect frame = CGRectMake(x + j * (itemW + 6), y, itemW, itemH);
                button.frame = frame;
                [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                SEL action = j == column -1 ? @selector(deleteAction:) : @selector(inputCharacterWithButton:);
                [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                if (j == column - 1) {
                    frame = CGRectMake(self.frame.size.width - 42 - 3, y, 42, itemH);
                    button.frame = frame;
                    [button setImage:[UIImage imageNamed:@"keyboard_cancel"] forState:UIControlStateNormal];
                    [button configButtonRoundCornerWithBackgroundColor:UIColorFromRGB(0xabb3be)];
                }
            }
            else if (i == 3) {
                CGFloat shiftW = (self.frame.size.width - (column - 2) * (self.frame.size.width - 6 - 6 * (column - 1)) / 10 - (column - 3) * 6 ) / 2 - 3 - 6;
                if (j == 0 || j == column - 1) {
                    itemW = shiftW;
                    int isLast= j== 0 ? 0 : 1;
                    CGRect frame = CGRectMake(3 + isLast * (self.frame.size.width - itemW - 6), y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:UIColorFromRGB(0xabb3be)];
                    SEL action = j == column -1 ? @selector(shiftToAlphabetKeyboardAction:) : @selector(shiftToNumberKeyboardAction:);
                    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    itemW = (self.frame.size.width - 6 - 6 * (column - 1)) / 10;
                    CGRect frame = CGRectMake(shiftW +3 + 6 + (j - 1) * (itemW + 6), y, itemW, itemH);
                    button.frame = frame;
                    [button configButtonRoundCornerWithBackgroundColor:[UIColor whiteColor]];
                    [button addTarget:self action:@selector(inputCharacterWithButton:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            [self addSubview:button];
        }
    }
}

#pragma mark- 按钮点击事件
- (void)hideKeyboardAction:(UIButton*)button {
    [self done];
}

- (void)numberBuyKeyboardDoneAction:(UIButton*)button {
    [self done];
}

- (void)deleteAction:(UIButton*)button {
    [self delete];
}

- (void)upperAction:(UIButton*)button {
    self.isUpper = !self.isUpper;

    int row = 5;
    for (int i = 0; i < row; i++) {
        NSArray *array = self.noupperArray[i];
        NSInteger column = array.count;
        for (int j = 0; j < column; j++) {
            UIButton *button = (UIButton*)[self viewWithTag:2000 + i * 100 + j];
            if (self.isUpper == YES) {
                [button setTitle:self.upperArray[i][j] forState:UIControlStateNormal];
            }
            else {
                [button setTitle:self.noupperArray[i][j] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)shiftToAlphabetKeyboardAction:(UIButton*)button {
    [self shiftActionWithType:MZKeyboardAlphabet];
}

- (void)shiftToNumberKeyboardAction:(UIButton*)button {
    [self shiftActionWithType:MZKeyboardNumberWithShift];
}


- (void)shiftToSymbolKeyboardAction:(UIButton*)button {
    [self shiftActionWithType:MZKeyboardSymbol];
}

#pragma mark- 键盘事件
- (void)done {
    if (self.inputSource && [self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.inputSource;
        if (textField.delegate && [textField.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
            BOOL shouldEnd= [textField.delegate textFieldShouldEndEditing:textField];
            MZKeyboard *keyboard = (MZKeyboard*)textField.inputView;
            [keyboard.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            keyboard = nil;
            textField.inputView = nil;
            [textField endEditing:shouldEnd];
        }else{
            [textField resignFirstResponder];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardClickOnButtonType:)]) {
        [self.delegate keyboardClickOnButtonType:DoneButton];
    }
}

- (void)delete {
    if (self.inputSource && [self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.inputSource;
        [textField deleteBackward];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardClickOnButtonType:)]) {
        [self.delegate keyboardClickOnButtonType:DeleteButton];
    }
}

- (void)inputCharacterWithButton:(UIButton*)button {
    NSString *title = button.titleLabel.text;
    if ([button.titleLabel.text isEqualToString:@"space"]) {
        title = @" ";
    }
    if (self.inputSource && [self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)self.inputSource;
        if (textField.delegate && [textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = NSMakeRange(textField.text.length, 1);
            BOOL shouldEnd = [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:title];
            if (shouldEnd) {
                [textField insertText:title];
            }
        }
        else {
            [textField insertText:title];
        }
    }
}

- (void)shiftActionWithType:(MZKeyboardType)type {
    UITextField *textField = (UITextField *)self.inputSource;
    MZKeyboard *keyboard = (MZKeyboard*)textField.inputView;
    [keyboard.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    keyboard = nil;
    textField.inputView = nil;
    textField.inputView = [[MZKeyboard alloc]createKeyboardByInputSource:textField withType:type isShowFeature:YES delegate:self.delegate];
    [textField reloadInputViews];
}

@end
