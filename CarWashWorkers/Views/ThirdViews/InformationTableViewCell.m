//
//  InformationTableViewCell.m
//  CarWashWorkers
//
//  Created by 黄承琪 on 15/8/19.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "InformationTableViewCell.h"
#import "WZLBadgeImport.h"
#import "CarWashWorkers.pch"
@implementation InformationTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    self.ContentsView.layer.cornerRadius = 5.0f;
//    [self.layer setBorderColor:[UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:0.80f].CGColor];
//    [self.ContentsView.layer setBorderWidth:0.30f];
    
//    self.ContentsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"talks"]];
//    [self.ContentsView.layer setBorderWidth:1];
//    [self.ContentsView.layer setBorderColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"talks"]].CGColor];
    
}
- (IBAction)SeeDetailsBtnClick:(UIButton *)sender {
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:self.UID forKey:@"id"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"wdxxxq"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        
        if (resultDic.count > 0) {
            NSDictionary *dic = [resultDic objectForKey:@"0"];
            if (dic.count > 0) {
                NSString *str = [dic objectForKey:@"news"];
                if (str.length > 0) {
                    [_delegate UnfoldList:self.IndexRow ListStr:str];
                }
                else{
                    [self.contentView makeToast:@"此条消息没有详情!"];
                }
            }
            else
            {
                [self.contentView makeToast:@"此消息没有详情"];
            
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
