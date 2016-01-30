//
//  ThirdTableViewCell.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "ThirdTableViewCell.h"

@implementation ThirdTableViewCell

- (void)awakeFromNib {
    // Initialization code
#pragma mark --内容view增加边框
    UIColor *whiteClocor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.ContView.layer setBorderWidth:0.8f];
    [self.ContView.layer setBorderColor:whiteClocor.CGColor];
    self.ContView.layer.cornerRadius = 5.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
