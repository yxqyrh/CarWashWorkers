//
//  HomeTableViewCell.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/20.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EstimateTimeChoose.h"

@protocol HomeTableViewCellDelegate <NSObject>

- (void)CompletionOfOrders;

@end



@interface HomeTableViewCell : UITableViewCell<UIAlertViewDelegate,EstimateTimeChooseDelegate>
/**内容view */
@property (weak, nonatomic) IBOutlet UIView *containerVIew;
/**车牌号label */
@property (weak, nonatomic) IBOutlet UILabel *LicensePlateLabel;
/**下单时间label */
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *OrderMarkLabel;

/**接单时间label */
@property (weak, nonatomic) IBOutlet UILabel *OrdersTimeLabel;
/**接单Btn */
@property (weak, nonatomic) IBOutlet UIButton *OrderBtn;
/**接单View */
@property (weak, nonatomic) IBOutlet UIView *OrderView;
/**洗车方式YES-内外全洗NO-车身清洗 */
@property (nonatomic,assign)BOOL IsWhole;
/**订单ID */
@property (nonatomic,copy)NSString *UID;

@property (nonatomic,strong)UITableView *tabel;

@property (nonatomic,copy)NSString *CountdownTime;
@property (nonatomic,copy)NSString *yjxcsj;

@property (nonatomic,strong)UIViewController *SVC;
@property (nonatomic ,assign)id <HomeTableViewCellDelegate	>delegate;
@end
