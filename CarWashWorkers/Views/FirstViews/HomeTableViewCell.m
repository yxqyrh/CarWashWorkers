//
//  HomeTableViewCell.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/20.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "CarWashWorkers.pch"
@implementation HomeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.containerVIew.layer.cornerRadius = 5.0f;
    self.containerVIew.layer.masksToBounds = YES;
    [self.containerVIew.layer setBorderWidth:1];
    [self.containerVIew.layer setBorderColor:[UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.00f].CGColor];
   
    if (self.IsWhole == YES) {
        self.OrderView.backgroundColor = RGBCOLOR(252, 151, 44);
    };
    self.OrderView.backgroundColor = RGBCOLOR(252, 151, 44);
    //
    [self.OrderMarkLabel sizeToFit];
   
}
-(void)setCountdownTime:(NSString *)CountdownTime
{
    _CountdownTime = CountdownTime;
    __block NSInteger timeout;
   // NSLog(@"剩余时间---%@",self.CountdownTime);
    if ([self.CountdownTime integerValue] > 0) {
        timeout = [self.CountdownTime integerValue]; //倒计时时间
    }
    else
    {
        timeout = 0; //倒计时时间
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.OrdersTimeLabel.text = @"(0秒)";
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                self.OrdersTimeLabel.text = [NSString stringWithFormat:@"(%ld秒)",(long)timeout];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);

}
- (IBAction)OrderBtnClick:(UIButton *)sender {
    
    NSLog(@"uid----%@",self.UID);
    
    EstimateTimeChoose *view = [EstimateTimeChoose defaultPopupView];
    view.parentVC = _SVC;
        view.delegate = self;
    [_SVC  lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:^{
        NSLog(@"动画结束");
    }];
//

    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121) {
        if (buttonIndex == 1) {
            
            [self.SVC.view makeToastActivity];
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            NSString *guserStr = [userDefaultes objectForKey:@"guser"];
            NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
            
            NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
            [postDic setObject:guserStr forKey:@"guser"];
            [postDic setObject:isloginidStr forKey:@"isloginid"];
            [postDic setObject:self.UID forKey:@"id"];
            [postDic setObject:APPKey forKey:@"key"];
            [postDic setObject:_yjxcsj forKey:@"yjxcsj"];
            
            //服务器给的域名
            NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"jsdd"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.SVC.view hideToastActivity];
                //json解析
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"点击接受订单------%@",resultDic);
                if (resultDic.count > 0) {
                    NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
                    switch (res) {
                        case 1:
                        {
                            [self.SVC.view makeToast:@"订单ID错误!"];
                        }
                            break;
                        case 2:
                        {
                            [self.SVC.view makeToast:@"接单失败!"];
                        }
                            break;
                        case 3:
                        {
                            [_delegate CompletionOfOrders];
                            [self.SVC.tabBarController setSelectedIndex:1];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"服务器出错,请联系我们!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
                
            } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"网络异常,请检测网络!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                
            }];

        }
        else
        {
            NSLog(@"2");
        }
        
        
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




-(void)setEstimateTimeChooseValue:(NSString *)value{
    _yjxcsj = value;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"是否确认接单?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 121;
        [alertView show];
}

@end
