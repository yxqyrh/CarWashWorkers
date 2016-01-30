//
//  SecondTableViewCell.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "SecondTableViewCell.h"




@implementation SecondTableViewCell

- (void)awakeFromNib {
    // Initialization code
#pragma mark --内容view增加边框
    UIColor *whiteClocor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.ContView.layer setBorderWidth:0.8f];
    [self.ContView.layer setBorderColor:whiteClocor.CGColor];
    self.ContView.layer.cornerRadius = 5.0f;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1Click)];
    [self.FirstImg addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2Click)];
    [self.SecondImg addGestureRecognizer:tap2];

    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap3Click)];
    [self.ThirdImg addGestureRecognizer:tap3];

    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap4Click)];
    [self.FourImg addGestureRecognizer:tap4];
    
}
-(void)tap1Click
{

    [imageBig
     showImage:self.FirstImg];
}
-(void)tap2Click
{
    [imageBig
     showImage:self.SecondImg];
}
-(void)tap3Click
{
    [imageBig
     showImage:self.ThirdImg];
}
-(void)tap4Click
{
    [imageBig
     showImage:self.FourImg];
}
//-(void)bTapClick
//{
//    self.SVC.navigationController.navigationBarHidden = NO;
//    self.SVC.tabBarController.tabBar.hidden = NO;
//
//    self.big.hidden = YES;
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
