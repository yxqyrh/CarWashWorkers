//
//  SecondViewController.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/12.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "SecondViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FirstTableViewCell.h"
#import "SecondTableViewCell.h"
#import "ThirdTableViewCell.h"
#import "HeaderView.h"
#import "SearchDataView.h"
#import "PSTAlertController.h"
#import "DateTools.h"


@interface SecondViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,FirstTableViewCellDelegate>
{
    /**当前订单 */
    NSMutableArray *firstArray;
    /**已经完成订单 */
    NSMutableArray *secondArray;
    /**已退订单 */
    NSMutableArray *thirdArray;
    /**下载图片数据源 */
    NSArray *imgArray;
    
    //table 脚部视图
    FCXRefreshFooterView *footerView;
    //选择
    LjjUISegmentedControl *ljjuisement;
    /**分页数 */
    NSInteger Page;
    /**数据源 */
    NSMutableArray *dataArray;
    /**切换的模块 */
    NSInteger Modules;
    /**收起显示 */
    BOOL _upOff;
    /**存储点击值Array */
    NSMutableArray *SectionArray;
    /**选择照片提示框 */
    UIActionSheet *myActionSheet;
    /**缓存图片路径Array */
    NSMutableDictionary *postImageDic;
    
    /**订单转让界面 */
    __weak IBOutlet UIView *ConfirmTransferView;
    /**洗车工编号 */
    __weak IBOutlet UITextField *WashNumbTextField;
    
    /** 洗车工列表 */
    __weak IBOutlet UITableView *WashWorkersTab;
    
    /** 洗车工列表数据源 */
    NSMutableArray *WashWorkersArray;
    /** 转让洗车工号 */
    NSString *DDID;
    
    NSString *_selectWashType;//洗车方式实体类
    int current_washtype;
    NSMutableArray *_washTypeArray;
    
    NSDate *_startDate;
    NSDate *_endDate;
}
/**选择view */
@property (weak, nonatomic) IBOutlet UIView *SelectView;
/**数据table */
@property (weak, nonatomic) IBOutlet UITableView *DataShowTable;

@property (strong, nonatomic) IBOutlet UIView *orderFilterView;

@property (strong, nonatomic) IBOutlet UIControl *startDateControl;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;

@property (strong, nonatomic) IBOutlet UIControl *endDateControl;

@property (strong, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) IBOutlet UIControl *washStyleControl;
@property (strong, nonatomic) IBOutlet UILabel *washStyleLabel;

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation SecondViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //初始化数据
    [self initData];    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *StoringStr = [userDefaultes objectForKey:@"Storing"];
    if ([StoringStr isEqualToString:@"YES"]) {
//        NSMutableArray *dataarr = [[NSMutableArray alloc]init];
//        [dataarr addObjectsFromArray:dataArray];
//        [userDefaultes setObject:dataarr forKey:@"dataArray"];
//        [userDefaultes synchronize];
    }
    else
    {
        [SectionArray removeAllObjects];
        [dataArray removeAllObjects];
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        [userDefaultes removeObjectForKey:@"UIDArray"];

    }
   
    
    
    
   
}
#pragma mark---------------viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ConfirmTransferView.hidden = YES;
    _orderFilterView.hidden = YES;
    _countLabel.layer.borderWidth = 0.5;
    _countLabel.layer.borderColor = GeneralLineCGColor;
    
    [self initDateView];
    
    UIView *view = [_startDateControl viewWithTag:1];
    view.backgroundColor = GeneralBackgroundColor;
    
    UIView *view1 = [_endDateControl viewWithTag:1];
    view1.backgroundColor = GeneralBackgroundColor;
    
    UIView *view2 = [_washStyleControl viewWithTag:1];
    view2.backgroundColor = GeneralBackgroundColor;
    
    
    [dataArray removeAllObjects];
    [self.DataShowTable reloadData];
    self.title = @"我的订单";
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    
    //增加选项卡
    CGFloat height = self.SelectView.frame.size.height*Multiple;
    ljjuisement =[[LjjUISegmentedControl alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    NSArray* ljjarray=[NSArray arrayWithObjects:@"当前订单",@"已完成订单",@"已退订单",@"订单管理",nil];
    [ljjuisement AddSegumentArray:ljjarray];
    ljjuisement.delegate = self;
    [ljjuisement selectTheSegument:0];
    [self.SelectView addSubview:ljjuisement];
    
    WashWorkersTab.delegate = self;
    WashWorkersTab.dataSource = self;
    
    //table
    self.DataShowTable.delegate  = self;
    self.DataShowTable.dataSource = self;
    self.DataShowTable.fd_debugLogEnabled = YES;
    self.DataShowTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak __typeof(self)weakSelf = self;
    //上拉加载更多
    footerView = [self.DataShowTable addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf loadMoreAction];
    }];
    //自动刷新
    footerView.autoLoadMore = NO;
    //缓存图片的路径array的初始化
    postImageDic = [[NSMutableDictionary alloc]init];
    //代理
    WashNumbTextField.delegate = self;
   // ConfirmTransferView.backgroundColor = [UIColor colorWithRed:0.40f green:0.40f blue:0.40f alpha:1.00f];
    
    
    
}
#pragma mark ----------------数据初始化
-(void)initData
{
    //选择初始化
    Modules = 0;
    //cell 收起相关
    SectionArray = [[NSMutableArray alloc]init];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *StoringStr = [userDefaultes objectForKey:@"Storing"];
    if ([StoringStr isEqualToString:@"YES"]) {
        [userDefaultes setObject:@"NO" forKey:@"Storing"];
        return;
    }
    
    firstArray = [[NSMutableArray alloc]init];
    secondArray = [[NSMutableArray alloc]init];
    thirdArray = [[NSMutableArray alloc]init];
    dataArray = [[NSMutableArray alloc]init];
    Page = 1;
    [self.view makeToastActivity];
   
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    //-------请求当前订单数据
    NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
    [postDic1 setObject:guserStr forKey:@"guser"];
    [postDic1 setObject:isloginidStr forKey:@"isloginid"];
    [postDic1 setObject:@"1" forKey:@"page"];
    [postDic1 setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr1 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"dqdd"];
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager1 POST:domainStr1 parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"当前订单列表-----:%@",resultDic);
        if (resultDic.count > 0) {
            firstArray = [resultDic objectForKey:@"list"];
            if ([firstArray isKindOfClass:[NSNull class]]) {
                [self.view makeToast:@"暂时没有当前订单!"];
                firstArray = [[NSMutableArray alloc]init];
                dataArray = [[NSMutableArray alloc]init];
                return ;
            }
            //刚进页面 数据源是firstArray
            dataArray = [NSMutableArray  arrayWithArray:firstArray];
            [self.view hideToastActivity];
            [self.DataShowTable reloadData];
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
    
    //-------请求当前订单数据
    NSMutableDictionary *postDic2  = [[NSMutableDictionary alloc]init];
    [postDic2 setObject:guserStr forKey:@"guser"];
    [postDic2 setObject:isloginidStr forKey:@"isloginid"];
    [postDic2 setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr2 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"xcglb"];
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    manager2.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager2 POST:domainStr2 parameters:postDic2 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
       // NSLog(@"洗车工列表-----:%@",resultDic);
        if (resultDic.count > 0) {
            WashWorkersArray = [resultDic objectForKey:@"list"];
            if ([WashWorkersArray isKindOfClass:[NSNull class]]) {
                WashWorkersArray = [[NSMutableArray alloc]init];
                return ;
            }
//            [WashWorkersTab reloadData];
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

-(void)BtnClickInitData
{
    //选择初始化
    Modules = 0;
    //cell 收起相关
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *StoringStr = [userDefaultes objectForKey:@"Storing"];
    if ([StoringStr isEqualToString:@"YES"]) {
        [userDefaultes setObject:@"NO" forKey:@"Storing"];
        return;
    }
    
    firstArray = [[NSMutableArray alloc]init];
    secondArray = [[NSMutableArray alloc]init];
    thirdArray = [[NSMutableArray alloc]init];
    dataArray = [[NSMutableArray alloc]init];
    Page = 1;
    [self.view makeToastActivity];
    
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    //-------请求当前订单数据
    NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
    [postDic1 setObject:guserStr forKey:@"guser"];
    [postDic1 setObject:isloginidStr forKey:@"isloginid"];
    [postDic1 setObject:@"1" forKey:@"page"];
    [postDic1 setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr1 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"dqdd"];
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager1 POST:domainStr1 parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"当前订单列表-----:%@",resultDic);
        if (resultDic.count > 0) {
            firstArray = [resultDic objectForKey:@"list"];
            if ([firstArray isKindOfClass:[NSNull class]]) {
                [self.view makeToast:@"暂时没有当前订单!"];
                firstArray = [[NSMutableArray alloc]init];
                dataArray = [[NSMutableArray alloc]init];
                return ;
            }
            //刚进页面 数据源是firstArray
            dataArray = [NSMutableArray  arrayWithArray:firstArray];
            [self.view hideToastActivity];
            [self.DataShowTable reloadData];
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

#pragma mark---------------点击事件区域
#pragma mark---订单管理的点击事件

-(void)initDateView
{
    if (_startDate == nil) {
        _startDate = [NSDate date];
    }
    
    if (_endDate == nil) {
        _endDate = [NSDate date];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _startDateLabel.text = [dateFormatter stringFromDate:_startDate];
    _endDateLabel.text = [dateFormatter stringFromDate:_endDate];
}

- (IBAction)startControlClicked:(id)sender {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
    }
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    _datePicker.date = _startDate;
    PSTAlertController *alertController = [PSTAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:PSTAlertControllerStyleActionSheet];
    [alertController addAction:[PSTAlertAction actionWithTitle:@"确定" style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        
        _startDate = _datePicker.date;
        DLog(@"选择了:%@", _startDate);
        [self initDateView];
    }]];
    
    [alertController addAction:[PSTAlertAction actionWithTitle:@"取消" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
        DLog(@"取消");
    }]];
    //    alertController.bounds = CGRectMake(0, 0, 320, 297);
    //    _datePicker.frame = CGRectMake(0, 0, 320, 220);
    [alertController.view addSubview:_datePicker];
    [alertController showWithSender:self.view controller:self animated:YES completion:nil];
}

- (IBAction)endDateControlClicked:(id)sender {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
    }
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    
    _datePicker.date = _endDate;
    PSTAlertController *alertController = [PSTAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:@"" preferredStyle:PSTAlertControllerStyleActionSheet];
    [alertController addAction:[PSTAlertAction actionWithTitle:@"确定" style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        
        _endDate = _datePicker.date;
        DLog(@"选择了:%@", _endDate);
        
        [self initDateView];
    }]];
    
    [alertController addAction:[PSTAlertAction actionWithTitle:@"取消" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
        DLog(@"取消");
    }]];
    //    alertController.bounds = CGRectMake(0, 0, 320, 297);
    //    _datePicker.frame = CGRectMake(0, 0, 320, 220);
    [alertController.view addSubview:_datePicker];
    [alertController showWithSender:self.view controller:self animated:YES completion:nil];
}

- (IBAction)washStyleClicked:(id)sender {
    WashStyleChoose *view = [WashStyleChoose defaultPopupView];
    view.parentVC = self;
    view.delegate = self;
    view.washTypeArray = _washTypeArray;
    view.current_seleted_row = current_washtype;
    [self lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:^{
        
    }];
}

- (IBAction)searchButtonClicked:(id)sender {
    [self ddcx];
}


-(void)ddcxxs
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    //-------请求当前订单数据
    NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
    [postDic1 setObject:guserStr forKey:@"guser"];
    [postDic1 setObject:isloginidStr forKey:@"isloginid"];
    [postDic1 setObject:APPKey forKey:@"key"];

    //服务器给的域名
    NSString *domainStr1 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ddcxxs"];
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager1 POST:domainStr1 parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view hideToastActivity];
        DLog(@"responseObject:%@",responseObject);
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"当前订单列表-----:%@",resultDic);
        if (resultDic.count > 0) {
            NSArray *fsArray = [resultDic objectForKey:@"scfs_list"];
            if (fsArray != nil && [fsArray isKindOfClass:[NSArray class]]) {
                _washTypeArray = [NSMutableArray array];
                for (NSDictionary *dic in fsArray) {
                    NSString *fs = [dic objectForKey:@"fs"];
                    [_washTypeArray addObject:fs];
                }
            }
            current_washtype = 0;
            _selectWashType = [_washTypeArray objectAtIndex:current_washtype];
            _washStyleLabel.text = _selectWashType;
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

-(void)ddcx
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    //-------请求当前订单数据
    NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
    [postDic1 setObject:guserStr forKey:@"guser"];
    [postDic1 setObject:isloginidStr forKey:@"isloginid"];
    
    [_startDate dateByAddingTimeInterval:-24 * 60 * 60];
    NSDate *ksDate = [NSDate dateWithYear:_startDate.year month:_startDate.month day:_startDate.day hour:0 minute:0 second:0];

    NSTimeInterval kstime = [ksDate timeIntervalSince1970];
    [postDic1 setValue:[NSNumber numberWithInt:kstime] forKey:@"kstime"];
    
    NSDate *jsDate = [NSDate dateWithYear:_endDate.year month:_endDate.month day:_endDate.day hour:23 minute:59 second:59];
    NSTimeInterval jstime = [jsDate timeIntervalSince1970];
    [postDic1 setValue:[NSNumber numberWithInt:jstime] forKey:@"jstime"];
    
     [postDic1 setObject:_selectWashType forKey:@"xcfs"];
    [postDic1 setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr1 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ddcx"];
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager1 POST:domainStr1 parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"当前订单列表-----:%@",resultDic);
        if (resultDic.count > 0) {
            NSString *count = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"count"]];
            _countLabel.text = count;
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

#pragma mark---展开 关闭cell
-(void)OpenBtnClick:(UIButton *)BtnS
{
    NSInteger BtnTag = BtnS.tag - 200;
    NSLog(@"测试tag---:%ld",(long)BtnTag);
    if (SectionArray.count == 0) {
        [SectionArray  addObject:[NSString stringWithFormat:@"%ld",(long)BtnTag]];
        
        
    }else
    {
        
            if ([SectionArray containsObject:[NSString stringWithFormat:@"%ld",(long)BtnTag]]) {
                
                [SectionArray removeObject:[NSString stringWithFormat:@"%ld",(long)BtnTag]];
            }
            else
            {
                [SectionArray addObject:[NSString stringWithFormat:@"%ld",(long)BtnTag]];
            }
        
    }
    NSLog(@"测试sectionArray---:%@",SectionArray);
    [self.DataShowTable reloadData];
    [self.DataShowTable beginUpdates];
    [self.DataShowTable endUpdates];
//    [self BtnClickInitData];
}

#pragma mark----------WashStyleChooseDelegate

- (void)setWashStyle:(int)index
{
    _selectWashType = [_washTypeArray objectAtIndex:index];
    current_washtype = index;
    _washStyleLabel.text = _selectWashType;
}

#pragma mark----------TransferChooseDelegate

- (void)selectWorker:(int)index;
{
    NSDictionary *worker = [WashWorkersArray objectAtIndex:index];
    

    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *SelectStr = [userDefaultes objectForKey:@"ID"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:[worker objectForKey:@"guser"] forKey:@"gusera"];
    [postDic setObject:[GlobalVar sharedSingleton].DDID forKey:@"id"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"zrdd"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            [WashNumbTextField resignFirstResponder];
            if (res == 1) {
                [self.view makeToast:@"订单转让成功!"];
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;
                [self initData];
            }
            else if(res == 2)
            {
                [self.view makeToast:@"订单转让失败!"];
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;
            }
            else
            {
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;
                
                
            }
        }
        else
        {
            [WashNumbTextField resignFirstResponder];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"服务器出错,请联系我们!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [WashNumbTextField resignFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"网络异常,请检测网络!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        
    }];
}

#pragma mark---------------LjjUISegmentedControlDelegate
-(void)uisegumentSelectionChange:(NSInteger)selection
{
    if (selection != 3) {
        _orderFilterView.hidden = YES;
        _DataShowTable.hidden = NO;
    }
    
    [dataArray removeAllObjects];
    [self.DataShowTable reloadData];
    Page  = 1;
    if (selection == 0) {
        [self.view makeToastActivity];
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        //-------请求当前订单数据
        NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
        [postDic1 setObject:guserStr forKey:@"guser"];
        [postDic1 setObject:isloginidStr forKey:@"isloginid"];
        [postDic1 setObject:@"1" forKey:@"page"];
        [postDic1 setObject:APPKey forKey:@"key"];
        //服务器给的域名
        NSString *domainStr1 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"dqdd"];
        AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
        manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager1 POST:domainStr1 parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.view hideToastActivity];
            
            //json解析
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            if (resultDic.count > 0) {
                firstArray = [resultDic objectForKey:@"list"];
                if ([firstArray isKindOfClass:[NSNull class]]) {
                    [self.view makeToast:@"暂时没有当前订单!"];
                    firstArray = [[NSMutableArray alloc]init];
                    dataArray = [[NSMutableArray alloc]init];
                   
                    [self.DataShowTable reloadData];
                    [self.DataShowTable beginUpdates];
                    [self.DataShowTable endUpdates];
                    
                    return ;
                }
                //刚进页面 数据源是firstArray
                dataArray = [NSMutableArray  arrayWithArray:firstArray];
                [self.DataShowTable reloadData];
                [self.DataShowTable beginUpdates];
                [self.DataShowTable endUpdates];
                [self.view hideToastActivity];
            }
            else
            {
                [self.view makeToast:@"服务器出错,请联系我们!"];
            }
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.view makeToast:@"网络异常,请检测网络!"];
        }];
        Modules = 0;
        [SectionArray removeAllObjects];
        [self.DataShowTable reloadData];
        [self.DataShowTable beginUpdates];
        [self.DataShowTable endUpdates];
        
    }
    else if (selection == 1)
    {
        [self.view makeToastActivity];
        //-------已完成订单
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        NSMutableDictionary *postDic2  = [[NSMutableDictionary alloc]init];
        [postDic2 setObject:guserStr forKey:@"guser"];
        [postDic2 setObject:isloginidStr forKey:@"isloginid"];
        [postDic2 setObject:@"1" forKey:@"page"];
        [postDic2 setObject:APPKey forKey:@"key"];
        //服务器给的域名
        NSString *domainStr2 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ywcdd"];
        AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
        manager2.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager2 POST:domainStr2 parameters:postDic2 success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.view hideToastActivity];
            //json解析
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            if (resultDic.count > 0) {
                secondArray = [resultDic objectForKey:@"list"];
                if ([secondArray isKindOfClass:[NSNull class]]) {
                    [self.view makeToast:@"暂时没有已完成订单!"];
                    dataArray = [[NSMutableArray alloc]init];
                    secondArray = [[NSMutableArray alloc]init];
                    
                    [self.DataShowTable reloadData];
                    [self.DataShowTable beginUpdates];
                    [self.DataShowTable endUpdates];
                   
                    return ;
                }
                dataArray = [[NSMutableArray alloc]initWithArray:secondArray];
               
                [self.DataShowTable reloadData];
                [self.DataShowTable beginUpdates];
                [self.DataShowTable endUpdates];
             

            }
            else
            {
                [self.view makeToast:@"服务器出错,请联系我们!"];
            }
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.view makeToast:@"网络异常,请检测网络!"];
        }];

        Modules = 1;
        [SectionArray removeAllObjects];
        [self.DataShowTable reloadData];
        [self.DataShowTable beginUpdates];
        [self.DataShowTable endUpdates];
        [postImageDic removeAllObjects];
        
    }
    else if (selection == 2)
    {
        
        //-------请求已退订单数据
        [self.view makeToastActivity];
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
        [postDic setObject:guserStr forKey:@"guser"];
        [postDic setObject:isloginidStr forKey:@"isloginid"];
        [postDic setObject:@"1" forKey:@"page"];
        [postDic setObject:APPKey forKey:@"key"];
        //服务器给的域名
        NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ytdd"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.view hideToastActivity];
            //json解析
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            if (resultDic.count > 0) {
                thirdArray = [resultDic objectForKey:@"list"];
                if ([thirdArray isKindOfClass:[NSNull class]]) {
                    dataArray = [[NSMutableArray alloc]init];
                    thirdArray = [[NSMutableArray alloc]init];
                    [self.view makeToast:@"暂时没有已退订单!"];
                   
                    [self.DataShowTable reloadData];
                    [self.DataShowTable beginUpdates];
                    [self.DataShowTable endUpdates];
             
                    return ;
                }
                 dataArray = [[NSMutableArray alloc]initWithArray:thirdArray];
           
                [self.DataShowTable reloadData];
                [self.DataShowTable beginUpdates];
                [self.DataShowTable endUpdates];
           

            }
            else
            {
                [self.view makeToast:@"服务器出错,请联系我们!"];
            }
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.view makeToast:@"网络异常,请检测网络!"];
        }];
        Modules = 2;
        [SectionArray removeAllObjects];
        [self.DataShowTable reloadData];
        [self.DataShowTable beginUpdates];
        [self.DataShowTable endUpdates];
        [postImageDic removeAllObjects];
    }
    else if (selection == 3) {
        _orderFilterView.hidden = NO;
        _DataShowTable.hidden = YES;
        
        [self ddcxxs];
    }

}
#pragma mark ---------------UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (Modules == 1) {
//        return dataArray.count+1;
//    }
    if (dataArray.count == 0) {
        return 0;
    }
   
    if ( tableView.tag == 1213) {
        return 1;
    }
    else
    return dataArray.count;
}
#pragma mark----头部视图
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (dataArray.count < 1) {
        return nil;
    }
    
        //普通视图
        HeaderView *hView = [[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:self options:nil]lastObject];
        NSDictionary *dic = [dataArray objectAtIndex:section];
        hView.OrderNumberLabel.text = [NSString stringWithFormat:@"订单编号：%@",[dic objectForKey:@"num"]];
        hView.OrderNumberLabel.adjustsFontSizeToFitWidth = YES;
#warning  tag 200+section
        hView.OpenBtn.tag = 200+section;
        NSInteger tags = section;
        //NSLog(@"选中数组----%@,tags----%ld",SectionArray,(long)tags);
        if ([SectionArray containsObject:[NSString stringWithFormat:@"%ld",(long)tags]]) {
        [hView.OpenBtn setImage:[UIImage imageNamed:@"downbt"] forState:UIControlStateNormal];
        }
    
    
        //NSLog(@"创建btn-tag--:%ld",(long)section);
        [hView.OpenBtn  addTarget:self action:@selector(OpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
        return hView;

    
    
}
#pragma mark ---cell的个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    //search 没有cell
//    if (Modules == 1 && section == 0) {
//        return 0;
//    }
    if ( tableView.tag == 1213) {
        return WashWorkersArray.count;
    }
    else
    {
        if (SectionArray.count >0) {
            if ([SectionArray containsObject:[NSString stringWithFormat:@"%ld",(long)section]]) {
                
                return 1;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }

}
#pragma mark--cell 初始化
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    static NSString *cellID = @"CellID";
    NSLog(@"选项-----%ld",(long)Modules);
    if (Modules == 0) {
        
        if ( tableView.tag == 1213) {
            
            UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"WashID"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WashID"];
            }
            NSDictionary *dic = [WashWorkersArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"gname"]];
            cell.userInteractionEnabled = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return  cell;
        }
        else
        {
            FirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"FirstTableViewCell" owner:self options:nil]lastObject];
            }
            //呈现区
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backGVC = self;
            cell.delegate = self;
            if (dataArray.count < 1) {
                return cell;
            }
            NSDictionary *dic = [dataArray objectAtIndex:indexPath.section];
            cell.LicensePlateLabel.text = [NSString stringWithFormat:@"车牌号：%@",[dic objectForKey:@"carnumber"]];
            cell.CarPostionLabel.text = [NSString stringWithFormat:@"车位号：%@",[dic objectForKey:@"cwh"]];
            cell.CarWashLabel.text = [NSString stringWithFormat:@"洗车方式：%@",[dic objectForKey:@"methods"]];
            cell.LocationLabel.text = [NSString stringWithFormat:@"洗车地点：%@",[dic objectForKey:@"szdqstr"]];
            cell.NumberingLabel.text = [NSString stringWithFormat:@"洗车工编号：%@",[dic objectForKey:@"guser"]];
            NSString *reinfStr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"remark"]];
            if (reinfStr.length > 0) {
                cell.RemarksInfoLabel.text = [NSString stringWithFormat:@"备注信息：%@",reinfStr];
            }
            else
            {
                cell.RemarksInfoLabel.text = @"备注信息：暂无";
            }
            NSString *jud =[NSString stringWithFormat:@"%@",[dic objectForKey:@"judge_zt"]];
            cell.judgeStrzt = [NSString stringWithFormat:@"%@",[dic objectForKey:@"judge_zt"]];
            cell.payStatus = [NSString stringWithFormat:@"%@",[dic objectForKey:@"judge_zf"]];
            
            cell.userID = [NSString stringWithFormat:@"%@",[dic objectForKey:@"uid"]];
            
            
            
            if ([jud isEqualToString:@"2"]) {
                if (cell.ContainViewF.hidden==NO) {
                    cell.ContainViewF.hidden = YES;
                    cell.TransferBtn.userInteractionEnabled = NO;
                    [cell.TransferBtn setBackgroundColor:[UIColor grayColor]];
                }
                
            }
            cell.UID = [dic objectForKey:@"id"];
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            if ([userDefaultes objectForKey:@"UIDArray"]) {
                NSMutableArray *UIDArray =  [[userDefaultes objectForKey:@"UIDArray"] mutableCopy];
                if ([UIDArray containsObject:cell.UID]) {
                    if (cell.ContainViewF.hidden==NO) {
                        cell.ContainViewF.hidden = YES;
                        cell.TransferBtn.userInteractionEnabled = NO;
                        [cell.TransferBtn setBackgroundColor:[UIColor grayColor]];
                    }
                }
            }

            NSString *imgStr = [dic objectForKey:@"xc_picture"];
            if (![imgStr isKindOfClass:[NSNull class]]) {
                if (imgStr.length > 0) {
                    imgArray = [imgStr componentsSeparatedByString:@"|"];
                    
//                    if ([jud isEqualToString:@"2"]) {
                        switch (imgArray.count) {
                            case 0:
                            {
                                cell.SecondImgBtn.hidden = YES;
                                break;
                            }
                            case 1:
                            {
                                [cell.FirstImgBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] forState:UIControlStateNormal];
                                
                                [cell.FirstImgBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    [cell.btnImageDic setObject:image forKey:@1000];
                                    NSDate * senddate=[NSDate date];
                                    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
                                    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
                                    NSString * morelocationString=[dateformatter stringFromDate:senddate];
                                    [cell.ImgNameArray addObject:morelocationString];
                                    
                                }];
                                
                                
                                break;
                            }
                            default:
                                break;
                                
                        }
//                    }
                }
            }

            //多线程请求
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            //2.把任务添加到队列中执行
            dispatch_async(queue, ^{
                
                
                NSString *str = [dic objectForKey:@"numtime"];//时间戳
                NSTimeInterval time=[str doubleValue] ;//因为时差问题要加8小时 == 28800 sec
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                //实例化一个NSDateFormatter对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
                
//                 [cell.FirstImageView setContentMode:UIViewContentModeScaleAspectFit];
//                 [cell.SecondImageView setContentMode:UIViewContentModeScaleAspectFit];
//                 [cell.ThirdImageView setContentMode:UIViewContentModeScaleAspectFit];
//                 [cell.FourImageView setContentMode:UIViewContentModeScaleAspectFit];
                NSString *imgStr = [dic objectForKey:@"xc_picture"];
                if (![imgStr isKindOfClass:[NSNull class]]) {
                    if (imgStr.length > 0) {
                        imgArray = [imgStr componentsSeparatedByString:@"|"];
                        switch (imgArray.count) {
                            case 1:
                            {
                                [cell.FirstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                            }
                                break;
                            case 2:
                            {
                                [cell.FirstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.SecondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                            }
                                break;
                            case 3:
                            {
                                [cell.FirstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.SecondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.ThirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                            }
                                break;
                            case 4:
                            {
                                [cell.FirstImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.SecondImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.ThirdImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:2]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                                [cell.FourImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                            }
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
                
                
                //回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    cell.TimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",currentDateStr];
                    //
                });
            });
            
            
            cell.ConfirmTransferView = ConfirmTransferView;
            cell.userInteractionEnabled = YES;
            
            cell.tranferBlock = ^() {
                if (WashWorkersArray == nil || WashWorkersArray.count == 0) {
                    [self.view makeToast:@"没有其他洗车工"];
                    return ;
                }
                
                TransferChoose *view = [TransferChoose defaultPopupView];
                view.parentVC = self;
                view.delegate = self;
                view.workers = WashWorkersArray;
                view.current_seleted_row = -1;
                [self lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:^{
                    
                }];
            };
            
            return cell;
        }
        
        
        
    }
    else if (Modules == 1)
    {
        SecondTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SecondTableViewCell" owner:self options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (dataArray.count < 1) {
            return cell;
        }
        NSDictionary  *dic = [dataArray objectAtIndex:indexPath.section];
        cell.LicensePlateLabel.text = [NSString stringWithFormat:@"车牌号：%@",[dic objectForKey:@"carnumber"]];
        cell.CarPostionLabel.text = [NSString stringWithFormat:@"车位号：%@",[dic objectForKey:@"cwh"]];
        cell.CarWashLabel.text = [NSString stringWithFormat:@"洗车方式：%@",[dic objectForKey:@"methods"]];
        cell.LocationLabel.text = [NSString stringWithFormat:@"洗车地点：%@",[dic objectForKey:@"szdqstr"]];
        cell.NumberingLabel.text = [NSString stringWithFormat:@"洗车工编号：%@",[dic objectForKey:@"guser"]];
        cell.SVC = self;
        //多线程请求
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //2.把任务添加到队列中执行
        dispatch_async(queue, ^{
            
            
            NSString *str = [dic objectForKey:@"numtime"];//时间戳
            NSTimeInterval time=[str doubleValue] ;//因为时差问题要加8小时 == 28800 sec
            NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
            //实例化一个NSDateFormatter对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
            
            NSString *str1 = [dic objectForKey:@"xctime"];//时间戳
            NSTimeInterval time1=[str1 doubleValue] ;//因为时差问题要加8小时 == 28800 sec
            NSDate *detaildate1=[NSDate dateWithTimeIntervalSince1970:time1];
            //实例化一个NSDateFormatter对象
            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr1= [dateFormatter1 stringFromDate: detaildate1];
            
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.TimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",currentDateStr];
                cell.WashTimeLabel.text = [NSString stringWithFormat:@"洗车时间：%@",currentDateStr1];
            });
        });
        
        //下载图片
        
//        [cell.FirstImg setContentMode:UIViewContentModeScaleAspectFit];
//        [cell.SecondImg setContentMode:UIViewContentModeScaleAspectFit];
//        [cell.ThirdImg setContentMode:UIViewContentModeScaleAspectFit];
//        [cell.FourImg setContentMode:UIViewContentModeScaleAspectFit];
        
        NSString *imgStr = [dic objectForKey:@"xc_picture"];
        if (imgStr.length > 0) {
            imgArray = [imgStr componentsSeparatedByString:@"|"];
            NSMutableArray *imgArr = [NSMutableArray arrayWithArray:imgArray];
            if ([imgArr containsObject:@""]) {
                [imgArr removeObject:@""];
            }
            imgArray = [NSArray arrayWithArray:imgArr];

            switch (imgArr.count) {
                case 1:
                {
                    [cell.FirstImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                }
                    break;
                case 2:
                {
                    [cell.FirstImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.SecondImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                }
                    break;
                case 3:
                {
                    [cell.FirstImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.SecondImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.ThirdImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                }
                    break;
                case 4:
                {
                    [cell.FirstImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.SecondImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.ThirdImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:2]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                    [cell.FourImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray lastObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
                }
                    break;
                    
                default:
                    break;
            }
        }
        if (imgArray.count > 4) {
            [cell.FirstImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray firstObject]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
            [cell.SecondImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
            [cell.ThirdImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:2]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
            [cell.FourImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,[imgArray objectAtIndex:3]]] placeholderImage:[UIImage imageNamed:@"upImg"]];
        }
        
        return cell;
    }
    else if(Modules == 2)
    {
        ThirdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ThirdTableViewCell" owner:self options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (dataArray.count < 1) {
            return cell;
        }
        NSDictionary *dic = [dataArray objectAtIndex:indexPath.section];
        cell.LicensePlateLabel.text = [NSString stringWithFormat:@"车牌号：%@",[dic objectForKey:@"carnumber"]];
        cell.CarWashLabel.text = [NSString stringWithFormat:@"洗车方式：%@",[dic objectForKey:@"methods"]];
        cell.LocationLabel.text = [NSString stringWithFormat:@"洗车地点：%@",[dic objectForKey:@"szdqstr"]];
        cell.NumberingLabel.text = [NSString stringWithFormat:@"洗车工编号：%@",[dic objectForKey:@"guser"]];
        //多线程请求
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //2.把任务添加到队列中执行
        dispatch_async(queue, ^{
            
            
            NSString *str = [dic objectForKey:@"numtime"];//时间戳
            NSTimeInterval time=[str doubleValue] ;//因为时差问题要加8小时 == 28800 sec
            NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
            //实例化一个NSDateFormatter对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
            
            
            NSString *ReasonStr = [NSString stringWithFormat:@"退订原因：%@",[dic objectForKey:@"unsubscribe"]];
            NSMutableAttributedString *Inforstr;
            Inforstr = [[NSMutableAttributedString alloc]
                   initWithString:ReasonStr];
                [Inforstr
                 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.63f green:0.63f blue:0.63f alpha:1.00f] range:NSMakeRange(0,5)];
            
            
            NSInteger judge =  [[dic objectForKey:@"judge_zt"] integerValue];
            NSString *StatusStr;
            switch (judge) {
                case 0:
                {
                 StatusStr = @"未接订单";
                }
                    break;
                case 1:
                {
                 StatusStr = @"已接订单";
                }
                    break;
                case 2:
                {
                 StatusStr = @"正在洗车";
                }
                    break;
                case 3:
                {
                 StatusStr = @"已退订";
                }
                    break;
                case 4:
                {
                    StatusStr = @"已完成订单";
                }
                    break;
                default:
                    break;
            }
            
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.TimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",currentDateStr];
                cell.ReasonLabel.attributedText = Inforstr;
                cell.StatusLabel.text = StatusStr;
            });
        });

        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        return cell;
    }

    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 刚选中又马上取消选中，格子不变色
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ( tableView.tag == 1213) {
        NSDictionary *dic = [WashWorkersArray objectAtIndex:indexPath.row];
        DDID = [dic objectForKey:@"guser"];
    }
}

#pragma mark----cell delegate
-(void)CompletionOfOrders
{
[ljjuisement selectTheSegument:1];
    
}

#pragma mark --section cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
//    //search 高度低
//    if (Modules == 1 && section == 0) {
//        return 60;
//    }
    if ( tableView.tag == 1213) {
        return 0;
    }
    return 53;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView.tag == 1213) {
        return 40;
    }

    if (Modules == 0) {
        return 465;////
    }
    else if (Modules == 1)
    {
        switch (imgArray.count) {
            case 0:
                return 215;
                break;
            case 1:
                return 309;
                break;
            case 2:
                return 309;
                break;
            case 3:
                return 425;
                break;
            case 4:
                return 425;
                break;
            default:
                return 425;
                break;
        }
    }
    else
    {
        return 226;
    }
}


#pragma mark------------------------------------订单转让

- (IBAction)CancleBtnClick:(UITapGestureRecognizer *)sender {
    self.tabBarController.tabBar.hidden =  NO;
    self.navigationController.navigationBarHidden = NO;
    ConfirmTransferView.hidden = YES;
}


- (IBAction)ConfirmTransferBtnClick:(UIButton *)sender {
    
    if (DDID.length == 0) {
        [self.view makeToast:@"请选择你想要转让的洗车工"];
        return;
    }
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *SelectStr = [userDefaultes objectForKey:@"ID"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:DDID forKey:@"gusera"];
    [postDic setObject:SelectStr forKey:@"id"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"zrdd"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            [WashNumbTextField resignFirstResponder];
            if (res == 1) {
                [self.view makeToast:@"订单转让成功!"];
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;
                [self initData];
            }
            else if(res == 2)
            {
                [self.view makeToast:@"订单转让失败!"];
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;
            }
            else
            {
                ConfirmTransferView.hidden = YES;
                self.tabBarController.tabBar.hidden =  NO;
                self.navigationController.navigationBarHidden = NO;

            
            }
        }
        else
        {
            [WashNumbTextField resignFirstResponder];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"服务器出错,请联系我们!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [WashNumbTextField resignFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"网络异常,请检测网络!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        
    }];

}
#pragma mark---------TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}
#pragma mark---------------------------上拉刷新
- (void)loadMoreAction {
    __weak UITableView *weakTableView = self.DataShowTable;
    __weak FCXRefreshFooterView *weakFooterView = footerView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //刷新事件
        Page ++;
        
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        
        NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
        [postDics setObject:guserStr forKey:@"guser"];
        [postDics setObject:isloginidStr forKey:@"isloginid"];
        [postDics setObject:[NSString stringWithFormat:@"%ld",(long)Page] forKey:@"page"];
        [postDics setObject:APPKey forKey:@"key"];
        
        //服务器给的域名
        NSString *domainStr;
        switch (Modules) {
            case 0:
            {
                domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"dqdd"];
            }
                break;
            case 1:
            {
                 domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ywcdd"];
            }
                break;
            case 2:
            {
                 domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ytdd"];
            }
                break;
            default:
                break;
        }
        
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
                [copyDataArray addObjectsFromArray:dataArray];
                [copyDataArray addObjectsFromArray:TemporaryArray];
                dataArray =  [NSMutableArray arrayWithArray:copyDataArray];
                [self.DataShowTable reloadData];
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
