//
//  EstimateTimeChoose.m
//  CarWashWorkers
//
//  Created by jingyaxie on 16/1/30.
//  Copyright © 2016年 ShiZhi. All rights reserved.
//

#import "EstimateTimeChoose.h"
@interface EstimateTimeChoose(){
    NSMutableArray *dataArray;
}
@end
@implementation EstimateTimeChoose

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        [self addSubview:_innerView];
        
    }
    dataArray = [[NSMutableArray alloc]initWithObjects:@"10分钟",@"25分钟",@"40分钟",@"60分钟",@"90分钟",@"大于120分钟", nil];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return self;
}

+ (instancetype)defaultPopupView{
    return [[EstimateTimeChoose alloc]initWithFrame:CGRectMake(0, 0, POP_WIDTH, 360)];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"CommonSingleChooseCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell= [[[NSBundle mainBundle]loadNibNamed:@"CommonSingleChooseCell" owner:nil options:nil] firstObject];
    }
    UILabel *title = [cell viewWithTag:1];
    title.text = dataArray[indexPath.row];
    UIImageView *image = [cell viewWithTag:2];
    if (indexPath.row == _current_seleted_row) {
        [image setImage:[UIImage imageNamed:@"selected"]];
    }else{
        [image setImage:[UIImage imageNamed:@"unselected"]];
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return  dataArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    _current_seleted_row = indexPath.row;
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(EstimateTimeChooseDelegate)]) { // 如果协议响应了sendValue:方法
        // 通知执行协议方法
        
        [_delegate setEstimateTimeChooseValue:indexPath.row];
        [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
    }
}
@end
