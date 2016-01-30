//
//  EstimateTimeChoose.h
//  CarWashWorkers
//
//  Created by jingyaxie on 16/1/30.
//  Copyright © 2016年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "LewPopupViewAnimationSlide.h"
#import "LewPopupViewAnimationSpring.h"
#import "LewPopupViewAnimationDrop.h"
@protocol EstimateTimeChooseDelegate<NSObject> // 代理传值方法
@required
- (void)setEstimateTimeChooseValue:(int)index;
@end

@interface EstimateTimeChoose : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak)UIViewController *parentVC;
@property (strong, nonatomic) IBOutlet UIView *innerView;
+ (instancetype)defaultPopupView;
@property (nonatomic) id<EstimateTimeChooseDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSInteger current_seleted_row;
@end
