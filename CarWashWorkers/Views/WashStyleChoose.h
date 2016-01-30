//
//  WashStyleChoose.h
//  MayiCar
//
//  Created by xiejingya on 9/27/15.
//  Copyright (c) 2015 xiejingya. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "LewPopupViewAnimationSlide.h"
#import "LewPopupViewAnimationSpring.h"
#import "LewPopupViewAnimationDrop.h"
@protocol WashStyleChooseDelegate<NSObject> // 代理传值方法
@required
- (void)setWashStyle:(int)index;
@end

@interface WashStyleChoose : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak)UIViewController *parentVC;
@property (strong, nonatomic) IBOutlet UIView *innerView;
+ (instancetype)defaultPopupView;
@property (nonatomic) id<WashStyleChooseDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property  NSArray *washTypeArray;//洗车方式列表
@property NSInteger current_seleted_row;
@end