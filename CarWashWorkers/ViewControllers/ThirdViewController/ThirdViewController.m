//
//  ThirdViewController.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/12.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "ThirdViewController.h"
#import "InformationTableViewCell.h"
#import "WZLBadgeImport.h"
@interface ThirdViewController ()<UITableViewDataSource,UITableViewDelegate,InformationTableViewCellDelegate>
{
    /**数据源 */
    NSMutableArray *DataArray;
    /**分页 */
    NSInteger Pages;
    //table 脚部视图
    FCXRefreshFooterView *footerView;
    /**点击详情数组 */
    NSMutableArray *IndexRoWArray;
    /**存储详情消息 */
    NSMutableArray *IndexShowArray;
}
/**消息Table */
@property (weak, nonatomic) IBOutlet UITableView *NewTableView;


@end

@implementation ThirdViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IndexRoWArray removeAllObjects];
    [IndexShowArray removeAllObjects];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //title
    self.title = @"我的消息";
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    //table
    self.NewTableView.delegate = self;
    self.NewTableView.dataSource = self;
    self.NewTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak __typeof(self)weakSelf = self;
    //上拉加载更多
    footerView = [self.NewTableView addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf loadMoreAction];
    }];
    //自动刷新
    footerView.autoLoadMore = NO;
    
    self.automaticallyAdjustsScrollViewInsets = false;
}
#pragma mark----------------------------初始化数据
-(void)initData
{
    [self.view makeToastActivity];
    IndexRoWArray = [[NSMutableArray alloc]init];
    IndexShowArray = [[NSMutableArray alloc]init];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:@"1" forKey:@"page"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"wdxx"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        [self.view hideToastActivity];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"我的消息------%@",resultDic);
        if (resultDic.count > 0) {
            DataArray = [resultDic objectForKey:@"list"];
            if ([DataArray isKindOfClass:[NSNull class]]) {
                [self.view makeToast:@"没有消息"];
                DataArray = [[NSMutableArray alloc]init];
                return ;
            }
            
            [self.NewTableView reloadData];
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



#pragma mark----------------------------UITableViewDelegate 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return DataArray.count;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TCellID";
    InformationTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"InformationTableViewCell" owner:self options:nil]lastObject];
    
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [DataArray objectAtIndex:indexPath.row];
    cell.TitleLabel.text = [dic objectForKey:@"title"];
    NSString *str = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if (![IndexRoWArray containsObject:str]) {
        cell.SecondView.hidden = YES;
    }
    else
    {
        
        NSUInteger indexL = [IndexRoWArray indexOfObject:str];
        cell.NumbLabel.text = [IndexShowArray objectAtIndex:indexL];
    }
    cell.IndexRow = indexPath.row;
    cell.delegate = self; 
    //多线程请求
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //2.把任务添加到队列中执行
    dispatch_async(queue, ^{
        
        
        NSString *str = [dic objectForKey:@"time"];//时间戳
        NSTimeInterval time=[str doubleValue] ;//因为时差问题要加8小时 == 28800 sec
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
        
        
        
        
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.TimeLabel.text = [NSString stringWithFormat:@"%@",currentDateStr];
        });
        cell.UID = [dic objectForKey:@"id"];
    });
    NSInteger judge = [[dic objectForKey:@"judge"] integerValue];
    if (judge == 0) {
        [cell.HeaderImageView showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
    }
    return cell;

}
#pragma mark--------cellDelegate
-(void)UnfoldList:(NSInteger)indexRow ListStr:(NSString *)listStr
{
    if ([IndexRoWArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexRow]]) {
        NSUInteger indexL = [IndexRoWArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)indexRow]];
        [IndexShowArray removeObjectAtIndex:indexL];
        [IndexRoWArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexRow]];
        [self.NewTableView reloadData];
        [self.NewTableView beginUpdates];
        [self.NewTableView endUpdates];
    }
    else
    {
        [IndexRoWArray addObject:[NSString stringWithFormat:@"%ld",(long)indexRow]];
        [IndexShowArray addObject:listStr];
        [self.NewTableView reloadData];
        [self.NewTableView beginUpdates];
        [self.NewTableView endUpdates];
    
    }
    


}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if ([IndexRoWArray containsObject:str]) {
        return 155;
    }
    else
    return 106;
}

#pragma mark---------------------------上拉刷新
- (void)loadMoreAction {
    __weak UITableView *weakTableView = self.NewTableView;
    __weak FCXRefreshFooterView *weakFooterView = footerView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //刷新事件
         Pages ++;
        
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        
        NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
        [postDics setObject:guserStr forKey:@"guser"];
        [postDics setObject:isloginidStr forKey:@"isloginid"];
        [postDics setObject:[NSString stringWithFormat:@"%ld",(long)Pages] forKey:@"page"];
        [postDics setObject:APPKey forKey:@"key"];
        
        //服务器给的域名
        NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"wdxx"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //json解析
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"刷新接单列表-----:%@",resultDic);
            if (resultDic.count > 0) {
                NSMutableArray *TemporaryArray = [resultDic objectForKey:@"list"];
                if ([TemporaryArray isKindOfClass:[NSNull class]]) {
                    [self.view makeToast:@"没有最新消息"];
                    return ;
                }
                //为数据源添加刷新得到的元素
                NSMutableArray *copyDataArray = [[NSMutableArray alloc]init];
                [copyDataArray addObjectsFromArray:DataArray];
                [copyDataArray addObjectsFromArray:TemporaryArray];
                DataArray =  [NSMutableArray arrayWithArray:copyDataArray];
                [self.NewTableView reloadData];
            }
            else
            {
                [self.view makeToast:@"服务器出错,请联系我们!"];
            }
            
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.view makeToast:@"网络异常,请检测网络!"];
        }];
        
        
        [weakTableView reloadData];
        [weakFooterView endRefresh];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
