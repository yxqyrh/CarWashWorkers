//
//  HeaderView.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/19.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView



/**订单编号 */
@property (weak, nonatomic) IBOutlet UILabel *OrderNumberLabel;
/**下单时间 */
@property (weak, nonatomic) IBOutlet UILabel *OrderTimeLabel;
/**展开关闭 */
@property (weak, nonatomic) IBOutlet UIButton *OpenBtn;
/**外部View */
@property (weak, nonatomic) IBOutlet UIView *contentVIew;
@end
