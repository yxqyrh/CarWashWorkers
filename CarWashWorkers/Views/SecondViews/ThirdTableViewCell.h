//
//  ThirdTableViewCell.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdTableViewCell : UITableViewCell

/**内容view */
@property (weak, nonatomic) IBOutlet UIView *ContView;
/**车牌号 */
@property (weak, nonatomic) IBOutlet UILabel *LicensePlateLabel;
/**洗车方式 */
@property (weak, nonatomic) IBOutlet UILabel *CarWashLabel;
/**洗车地点 */
@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;
/**洗车工编号 */
@property (weak, nonatomic) IBOutlet UILabel *NumberingLabel;
/**下单时间 */
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
/**退订原因 */
@property (weak, nonatomic) IBOutlet UILabel *ReasonLabel;
/**退订状态 */
@property (weak, nonatomic) IBOutlet UILabel *StatusLabel;
@end
