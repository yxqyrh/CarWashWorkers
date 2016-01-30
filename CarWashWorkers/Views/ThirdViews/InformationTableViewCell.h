//
//  InformationTableViewCell.h
//  CarWashWorkers
//
//  Created by 黄承琪 on 15/8/19.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol InformationTableViewCellDelegate <NSObject>

- (void)UnfoldList:(NSInteger)indexRow ListStr:(NSString *)listStr;

@end

@interface InformationTableViewCell : UITableViewCell
/**头部img */
@property (weak, nonatomic) IBOutlet UIImageView *HeaderImageView;
/**内容view */
@property (weak, nonatomic) IBOutlet UIView *ContentsView;
/**标题label */
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
/**时间Label */
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
/**详情btn */
@property (weak, nonatomic) IBOutlet UIButton *DetailBtnClick;

/**订单ID */
@property (nonatomic,copy) NSString *UID;

@property (weak, nonatomic) IBOutlet UIView *SecondView;



/**news */
@property (weak, nonatomic) IBOutlet UILabel *NumbLabel;


@property(nonatomic,assign) NSInteger IndexRow;

@property (nonatomic ,assign)id <InformationTableViewCellDelegate>delegate;



@end
