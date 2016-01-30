//
//  PersonakInfoViewController.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/10/8.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonakInfoViewController : UIViewController
/** 头像view */
@property (weak, nonatomic) IBOutlet UIView *HeaderImgView;
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImage;
/** 用户姓名view */
@property (weak, nonatomic) IBOutlet UIView *UserNameVIew;
@property (weak, nonatomic) IBOutlet UITextField *UserNameFiled;


/** 身份证号view */
@property (weak, nonatomic) IBOutlet UIView *IdentityView;
@property (weak, nonatomic) IBOutlet UITextField *IdentityField;


/** 手机号码view */
@property (weak, nonatomic) IBOutlet UIView *IphoneNumView;
@property (weak, nonatomic) IBOutlet UITextField *IphoneNumField;


/** 修改密码view */
@property (weak, nonatomic) IBOutlet UIView *ModifyPassView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ModifyBtn;


/** 确认编辑Btn */
@property (weak, nonatomic) IBOutlet UIButton *SureEditorBtn;


/** 退出登录Btn */
@property (weak, nonatomic) IBOutlet UIButton *SignOutBtn;




@end
