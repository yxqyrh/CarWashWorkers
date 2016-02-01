//
//  SecondViewController.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/12.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LjjUISegmentedControl.h"
#import "WashStyleChoose.h"
#import "WashType.h"
#import "TransferChoose.h"
#import "UIButton+WebCache.h"

@interface SecondViewController : UIViewController<LjjUISegmentedControlDelegate,WashStyleChooseDelegate,TransferChooseDelegate>

@end
