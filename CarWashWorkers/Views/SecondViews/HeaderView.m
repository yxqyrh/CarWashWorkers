//
//  HeaderView.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/19.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self.contentVIew.layer setBorderWidth:1];
    [self.contentVIew.layer setBorderColor:[UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.00f].CGColor];
    self.contentVIew.layer.cornerRadius = 5.f;
}




@end
