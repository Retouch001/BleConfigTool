//
//  BaseTextField.m
//  iBreezeeConfig
//
//  Created by Tang Retouch on 2018/3/22.
//  Copyright © 2018年 Tang Retouch. All rights reserved.
//

#import "BaseTextField.h"

@implementation BaseTextField

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initCode];
}


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCode];
    }
    return self;
}

- (void)initCode{
    [self setValue:UIColorHex(0x7983a2) forKeyPath:@"_placeholderLabel.textColor"]; //设置光标颜色和文字颜色一致
    self.textColor = UIColor.whiteColor;
    
    //self.font = [UIFont systemFontOfSize:16];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_clearbutton"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)]; // Required for iOS7
    [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = button;
    self.rightViewMode = UITextFieldViewModeWhileEditing;
    
    self.layer.cornerRadius = 5;
}






// 控件抖动效果

-(void)shakeView:(UIView*)viewToShake

{
    
    CGFloat t =2.0;
    
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    
    
    viewToShake.transform = translateLeft;
    
    
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        
        [UIView setAnimationRepeatCount:2.0];
        
        viewToShake.transform = translateRight;
        
    } completion:^(BOOL finished){
        
        if(finished){
            
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                
                viewToShake.transform =CGAffineTransformIdentity;
                
            } completion:NULL];
            
        }
        
    }];
    
}



-(void)clear:(id)sender{
    self.text = @"";
}

@end
