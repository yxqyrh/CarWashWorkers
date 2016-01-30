//
//  SearchDataView.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/25.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "SearchDataView.h"

@implementation SearchDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect {
    // Drawing code
#pragma mark --内容view增加边框
    UIColor *whiteClocor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.ContVIew.layer setBorderWidth:1.0f];
    [self.ContVIew.layer setBorderColor:whiteClocor.CGColor];
    self.ContVIew.layer.cornerRadius = 5.0f;
}

@end
