//
//  WashStyleChoose.m
//  MayiCar
//
//  Created by xiejingya on 9/27/15.
//  Copyright (c) 2015 xiejingya. All rights reserved.
//

#import "TransferChoose.h"
//#import "CommonMacro.h"
#import "WashType.h"



@implementation TransferChoose


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
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return self;
}

+ (instancetype)defaultPopupView{
    return [[TransferChoose alloc]initWithFrame:CGRectMake(0, 0, POP_WIDTH, 310)];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"TransferCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell= [[[NSBundle mainBundle]loadNibNamed:@"TransferCell" owner:nil options:nil] firstObject];
    }
        
    UIView *view = [cell viewWithTag:10];
    view.layer.borderColor = GeneralLineCGColor;
    view.layer.borderWidth = 0.5;
        
    NSDictionary *dic = [_workers objectAtIndex:indexPath.row];
    UILabel *title = [cell viewWithTag:1];

    title.text = [dic objectForKey:@"gname"];
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
    if(_workers == nil)
    {
        return 0;
    }
    return  _workers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 44;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
     _current_seleted_row = indexPath.row;
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(TransferChooseDelegate)]) { // 如果协议响应了sendValue:方法
        // 通知执行协议方法
        
        [_delegate selectWorker:indexPath.row];
        [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
    }
}
@end
