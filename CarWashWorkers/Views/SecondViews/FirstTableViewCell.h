//
//  FirstTableViewCell.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imageBig.h"
@protocol FirstTableViewCellDelegate <NSObject>

- (void)CompletionOfOrders;

@end
typedef void(^tranferClickBlock)(void);

@interface FirstTableViewCell : UITableViewCell<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)imageBig *big;

/**内容view */
@property (weak, nonatomic) IBOutlet UIView *contView;
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
/**备注信息 */
@property (weak, nonatomic) IBOutlet UILabel *RemarksInfoLabel;


#pragma mark--------内容页面一
/**内容页面一 */
@property (weak, nonatomic) IBOutlet UIView *ContainViewF;
/**第一张ImageView */
@property (weak, nonatomic) IBOutlet UIImageView *FirstImageView;
/**第二张图片View */
@property (weak, nonatomic) IBOutlet UIImageView *SecondImageView;
/**第三张图片View */
@property (weak, nonatomic) IBOutlet UIImageView *ThirdImageView;
/**第四张图片View */
@property (weak, nonatomic) IBOutlet UIImageView *FourImageView;



#pragma mark--------内容页面二
/**内容页面二 */
@property (weak, nonatomic) IBOutlet UIView *ContainViewS;
/**下单时间 */
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
/**第一张ImgBtn */
@property (weak, nonatomic) IBOutlet UIButton *FirstImgBtn;

/**第二张ImgBtn */
@property (weak, nonatomic) IBOutlet UIButton *SecondImgBtn;


/**第三张ImgBtn */
@property (weak, nonatomic) IBOutlet UIButton *ThirdImgBtn;

/**第四张ImgBtn */
@property (weak, nonatomic) IBOutlet UIButton *FourImgBtn;

/**联系车主Btn */
@property (weak, nonatomic) IBOutlet UIButton *ContactBtn;
/**订单转让Btn */
@property (weak, nonatomic) IBOutlet UIButton *TransferBtn;
/**订单确认Btn */
@property (weak, nonatomic) IBOutlet UIButton *SureBtn;

#pragma mark -------参数传入
/**弹出页面 */
@property (nonatomic,strong) UIViewController *backGVC;
/**订单ID */
@property (nonatomic,copy) NSString *UID;
/**订单转让界面 */
@property (nonatomic,strong) UIView *ConfirmTransferView;
/**是否开始洗车了 */
@property (nonatomic,copy) NSString *judgeStrzt;

/**用户手机号 */
@property (nonatomic,copy)NSString *userID;

@property (nonatomic,copy)NSString *payStatus;

@property (nonatomic,copy)UITableView *OutTabView;

/**洗车工 */
@property (nonatomic,copy)NSDictionary *workerDic;

@property (nonatomic, copy)tranferClickBlock tranferBlock;

@property (nonatomic ,assign)id <FirstTableViewCellDelegate>delegate;

@property (nonatomic, copy)NSMutableDictionary *btnImageDic;

/**存储图片名称DataArray */
@property (nonatomic, copy)NSMutableArray  *ImgNameArray;

/**存储图片DataArray */
@property (nonatomic, copy)NSMutableArray  *dataImgArray;

@end
