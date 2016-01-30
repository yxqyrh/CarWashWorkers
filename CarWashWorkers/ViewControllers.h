//
//  ViewController.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/11.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@interface ViewControllers : UIViewController<UITableViewDataSource,UITableViewDelegate>
/**订单tabel */
@property (weak, nonatomic) IBOutlet UITableView *WorkListTabelView;
@property (strong, nonatomic) IBOutlet UIButton *ddymButton;

@end

