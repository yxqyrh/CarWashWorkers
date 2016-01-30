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
@protocol TransferChooseDelegate<NSObject> // 代理传值方法
@required
- (void)selectWorker:(int)index;
@end

@interface TransferChoose : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak)UIViewController *parentVC;
@property (strong, nonatomic) IBOutlet UIView *innerView;
+ (instancetype)defaultPopupView;
@property (nonatomic) id<TransferChooseDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property  NSArray *workers;//洗车工列表
@property NSInteger current_seleted_row;
@end