//
//  SecondTableViewCell.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imageBig.h"
@interface SecondTableViewCell : UITableViewCell
@property (nonatomic,strong)imageBig *big;
/**内容view */
@property (weak, nonatomic) IBOutlet UIView *ContView;
/**车牌号 */
@property (weak, nonatomic) IBOutlet UILabel *LicensePlateLabel;

/**车牌号 */
@property (weak, nonatomic) IBOutlet UILabel *CarPostionLabel;
/**洗车方式 */
@property (weak, nonatomic) IBOutlet UILabel *CarWashLabel;
/**洗车地点 */
@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;
/**洗车工编号 */
@property (weak, nonatomic) IBOutlet UILabel *NumberingLabel;
/**下单时间 */
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
/**洗车时间 */
@property (weak, nonatomic) IBOutlet UILabel *WashTimeLabel;

/**第一张Img */
@property (weak, nonatomic) IBOutlet UIImageView *FirstImg;
/**第二张Img */
@property (weak, nonatomic) IBOutlet UIImageView *SecondImg;
/**第三张Img */
@property (weak, nonatomic) IBOutlet UIImageView *ThirdImg;
/**第四张Img */
@property (weak, nonatomic) IBOutlet UIImageView *FourImg;

@property (nonatomic,strong)UIViewController *SVC;
@end
