//
//  ViewController.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/11.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "ViewControllers.h"
#import "HomeTableViewCell.h"
#import "PersonakInfoViewController.h"
#import "PSTAlertController.h"
#import "EstimateTimeChoose.h"
@interface ViewControllers ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate,HomeTableViewCellDelegate>

{
   
//------------------------------登录
    /**登录账号 */
    __weak IBOutlet UITextField *UserNameField;
    /**登录密码 */
    __weak IBOutlet UITextField *ParssWordField;
    

    
//------------------------------首页
    /**数据源 */
    NSMutableArray *DataArray;
    //table 脚部视图
    FCXRefreshFooterView *footerView;
    //table 头部视图
    FCXRefreshHeaderView *headerView;
    /**接单页数 */
    NSInteger Pages;
    
    int _ddym;
    
   }
//------------------------------登录
/**登陆 */
@property (weak, nonatomic) IBOutlet UIView *LandedView;
/**首页 */
@property (weak, nonatomic) IBOutlet UIView *HomeView;
/**项目图标 */
@property (weak, nonatomic) IBOutlet UIImageView *IconImageVIew;
/**输入界面 */
@property (weak, nonatomic) IBOutlet UIView *EnterView;
/**标题栏背景 */
@property (weak, nonatomic) IBOutlet UIView *IconBgVIew;


//------------------------------首页
/**头像imageview */
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
/**姓名label */
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
/**工号label */
@property (weak, nonatomic) IBOutlet UILabel *JobNumberLabel;



@end

@implementation ViewControllers
-(void)NoticfloadData
{
    [self loadData];
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"蚂蚁小哥赶快接单啦！" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    alert.tag = 1513;
//    [alert show];

}
-(void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear: animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoticfloadData) name:@"dingdan" object:nil];
    [self apperInitHomeView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    // Do any additional setup after loading the view, typically from a nib.
    [self initLandedView];
    [self initHomeView];
    
      
    
}
#pragma mark ------------------------点击事件区
#pragma mark --点击事件登录
- (IBAction)EdBtnClick:(UIButton *)sender {
    PersonakInfoViewController *perVC = [[PersonakInfoViewController alloc]init];
    [self.navigationController pushViewController:perVC animated:YES];
}

//忘记密码
- (IBAction)ForgotPasswordBtnClick:(UIButton *)sender {
}
//登录
- (IBAction)LogInBtnClick:(UIButton *)sender {


    //
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    if (month > 11 || year == 2016) {
//        [self.view makeToast:@"软件失效!"];
//        self.LandedView.hidden = NO;
//        self.navigationController.navigationBarHidden = YES;
//        self.tabBarController.tabBar.hidden = YES;
//        return;
    }


    [UserNameField resignFirstResponder];
    [ParssWordField resignFirstResponder];
    //判断登录账号与密码是否为空
    if (UserNameField.text.length  <= 0) {
        [self.view makeToast:@"登录账号为空!"];
        return;
    }
    if (ParssWordField.text.length <= 0) {
        [self.view makeToast:@"登录密码为空!"];
        return;
    }
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    //测试账号  qw108077 123456
    [postDic setObject:UserNameField.text forKey:@"guser"];
    [postDic setObject:ParssWordField.text forKey:@"gpassword"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"xcglogin"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger resStr = [[resultDic objectForKey:@"res"] integerValue];
            /*
             阶段一
             判断结果 成功 识别
             成功解析存储 guser 洗车工工号 isloginid 随机ID
             失败 --弹出框
             */
            switch (resStr) {
                case 1:
                {
                    [self.view makeToast:@"该账号不存在!"];
                }
                    break;
                case 2:
                {
                    [self.view makeToast:@"密码错误!"];
                }
                    break;
                case 3:
                {
                    
                    NSString *guserStr = [resultDic objectForKey:@"guser"];
                    NSString *isloginidStr = [resultDic objectForKey:@"isloginid"];
                    if (guserStr.length <= 0 || isloginidStr <=0) {
                        [self.view makeToast:@"服务器出错,请联系我们!"];
                        return ;
                    }
                    //存储guserStr isloginidStr
                    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                    [userDefaultes setObject:guserStr forKey:@"guser"];
                    [userDefaultes setObject:isloginidStr forKey:@"isloginid"];
                    [userDefaultes setObject:ParssWordField.text forKey:@"PassWord"];
                    [userDefaultes synchronize];
                    
                    NSString *clientId = [userDefaultes objectForKey:@"clientId"];
                    
                    NSMutableDictionary *postDic1  = [[NSMutableDictionary alloc]init];
                    [postDic1 setObject:guserStr forKey:@"guser"];
                    [postDic1 setObject:isloginidStr forKey:@"isloginid"];
                    [postDic1 setObject:clientId forKey:@"wym"];
                    [postDic1 setObject:APPKey forKey:@"key"];
                    
                    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"bdwym"];
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    [manager POST:domainStr parameters:postDic1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //json解析
                        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                        NSLog(@"上传clientId------%@",resultDic);
                        if (resultDic.count > 0) {
                            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
                            if (res ==1) {
                                NSLog(@"用户绑定唯一码成功 ");
                            }
                            else
                            {
                                NSLog(@"用户绑定唯一码失败 ");
                            }
                        }
                        
                        
                    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                        NSLog(@"上传唯一码出错");
                    }];
                    
                    
                    /*
                     阶段二
                     页面跳转动画
                     开启tableview自动刷新
                     */
//                    CATransition *animation = [CATransition animation];
//                    animation.delegate = self;
//                    animation.duration = 0.5;
//                    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//                    animation.type = kCATransitionReveal;
//                    
//                    NSUInteger one = [[self.view subviews] indexOfObject:self.LandedView];
//                    NSUInteger two = [[self.view subviews] indexOfObject:self.HomeView];
//                    self.tabBarController.tabBar.hidden = NO;
//                    self.navigationController.navigationBarHidden = NO;
//                    [self.view exchangeSubviewAtIndex:one withSubviewAtIndex:two];
//                    [[self.view layer] addAnimation:animation forKey:@"animation"];
                    self.LandedView.hidden = YES;
                    self.navigationController.navigationBarHidden = NO;
                    self.tabBarController.tabBar.hidden = NO;
//                    //自动刷新
//                    footerView.autoLoadMore = YES;
                    /*
                     阶段三
                     请求接单列表
                     */
                    NSMutableDictionary *postDics10  = [[NSMutableDictionary alloc]init];
                    [postDics10 setObject:guserStr forKey:@"guser"];
                    [postDics10 setObject:isloginidStr forKey:@"isloginid"];
                    [postDics10 setObject:@"1" forKey:@"page"];
                    [postDics10 setObject:APPKey forKey:@"key"];
                    
                    //服务器给的域名
                    NSString *domainStr12 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"jdlb"];
                    AFHTTPRequestOperationManager *manager12 = [AFHTTPRequestOperationManager manager];
                    manager12.responseSerializer = [AFHTTPResponseSerializer serializer];
                    [manager POST:domainStr12 parameters:postDics10 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //json解析
                        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//                        NSLog(@"接单列表-----:%@",resultDic);
                        if (resultDic.count > 0) {
                            DataArray = [resultDic objectForKey:@"list"];
                            if ([DataArray isKindOfClass:[NSNull class]]) {
                                [self.view makeToast:@"没有订单!"];
                                DataArray = [[NSMutableArray alloc]init];
                                return ;
                            }
                            _ddym = [[resultDic objectForKey:@"ddym"] intValue];
                            if (_ddym == 1) {
                                _ddymButton.backgroundColor = RGBCOLOR(73, 180, 252);;
                                _ddymButton.userInteractionEnabled = YES;
                            }
                            else if (_ddym == 2) {
                                _ddymButton.backgroundColor = [UIColor lightGrayColor];
                                _ddymButton.userInteractionEnabled = NO;
                            }
                            //数组排序 DataArray数组里个数必须大于0
                            [self.WorkListTabelView reloadData];
                        }
                        else
                        {
                            [self.view makeToast:@"服务器出错,请联系我们!"];
                        }
                        
                    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                        [self.view makeToast:@"网络异常,请检测网络!"];
                    }];
                    
                    
                    //请洗车工个人信息
                    NSMutableDictionary *postDic3  = [[NSMutableDictionary alloc]init];
                    [postDic3 setObject:guserStr forKey:@"guser"];
                    [postDic3 setObject:isloginidStr forKey:@"isloginid"];
                    [postDic3 setObject:APPKey forKey:@"key"];
                    //服务器给的域名
                    NSString *domainStr3 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"grxx"];
                    AFHTTPRequestOperationManager *manager3 = [AFHTTPRequestOperationManager manager];
                    manager3.responseSerializer = [AFHTTPResponseSerializer serializer];
                    [manager3 POST:domainStr3 parameters:postDic3 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //json解析
                        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                        NSLog(@"ge------%@",resultDic);
                        if (resultDic.count > 0) {
                            NSDictionary *dataDic = [resultDic objectForKey:@"grxx"];
                            if ([dataDic isKindOfClass:[NSNull class]] ) {
                                [self.view makeToast:@"网络异常，请保持网络环境良好!"];
                                return ;
                            }
                            self.NameLabel.text = [dataDic objectForKey:@"gname"];
                            self.JobNumberLabel.text = [dataDic objectForKey:@"guser"];
                            NSString *imageURLStr = [dataDic objectForKey:@"gpicture"];
                            [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,imageURLStr]] placeholderImage:[UIImage imageNamed:@"headerImg"]];
                            //存储头像 姓名 身份证号  手机号码
                            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                            
                            NSString *HeaderURL = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gpicture"]];
                            if ([HeaderURL isKindOfClass:[NSNull class]]) {
                                HeaderURL = nil;
                            }
                            NSString *UserName = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gname"]];
                            NSString *IdentityStr = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"sfz"]];
                            NSString *IphoneNumStr = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gphone"]];
                            
                            [userDefaultes setObject:HeaderURL forKey:@"HeaderURL"];
                            [userDefaultes setObject:UserName forKey:@"UserName"];
                            [userDefaultes setObject:IdentityStr forKey:@"IdentityStr"];
                            [userDefaultes setObject:IphoneNumStr forKey:@"IphoneNumStr"];
                            [userDefaultes synchronize];
                            
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
                    break;
                    
                case 5:
                {
                    [self.view makeToast:@"该账号已在其他手机上登录!"];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
        NSLog(@"---获取到的json格式的字典--%@",resultDic);
        
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}




#pragma mark - ******************************数组倒序
-(NSMutableArray *)ArrayCompare:(NSMutableArray *)DataaArray
{
    NSMutableArray *backArray = [NSMutableArray arrayWithArray:DataaArray];
    NSSortDescriptor *delay = [NSSortDescriptor sortDescriptorWithKey:@"gqtime.integerValue" ascending:YES];
    [backArray sortUsingDescriptors:[NSArray arrayWithObject:delay]];
    
    return backArray;
}
#pragma mark --点击事件首页

//rightBarButtonItem
-(void)rightBarClick
{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4008778675"];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

//------------------------其他
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [UserNameField resignFirstResponder];
    [ParssWordField resignFirstResponder];
}

- (IBAction)ddymButtonClicked:(id)sender {
    PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:@"提示" message:@"确认订单已满？" preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[PSTAlertAction actionWithTitle:@"确定" handler:^(PSTAlertAction *action) {
        [self ddymAction];
    }]];
    [controller addAction:[PSTAlertAction actionWithTitle:@"取消" style:PSTAlertActionStyleCancel handler:nil]];
    [controller showWithSender:self.view controller:self animated:YES completion:nil];
}

-(void)ddymAction
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak FCXRefreshHeaderView *weakHeaderView = headerView;
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
    [postDics setObject:guserStr forKey:@"guser"];
    [postDics setObject:isloginidStr forKey:@"isloginid"];

    
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ddme"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakHeaderView endRefresh];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            int res  = [[resultDic objectForKey:@"res"] intValue];
            if (res == 1) {
                [self.view makeToast:@"请求成功"];
                _ddymButton.backgroundColor = [UIColor lightGrayColor];
                _ddymButton.userInteractionEnabled = NO;
            }
            else {
                [self.view makeToast:@"请求失败"];
            }
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

#pragma mark ------------------------界面初始化区
/**初始化登陆界面 */
-(void)initLandedView
{
    //图标圆角
    self.IconImageVIew.layer.masksToBounds  = YES;
    [self setImageForcornerRadius: self.IconImageVIew BoardWidth:0];
    //登录view 设置边框
    self.EnterView.layer.borderWidth = 1.1;
    [self.EnterView.layer setBorderColor:[UIColor colorWithRed:0.71f green:0.71f blue:0.71f alpha:1.00f].CGColor];
    self.EnterView.layer.cornerRadius = 6;
    //
    self.IconBgVIew.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    //
    UserNameField.delegate  = self;
    ParssWordField.delegate = self;
    ParssWordField.secureTextEntry = YES;
    
    
}
/**初始化首界面 */
-(void)initHomeView
{
    //头像圆角
    self.headerImageView.layer.masksToBounds  = YES;
    [self setImageForcornerRadius: self.headerImageView BoardWidth:5];
   //设置UINavigationBar
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.15f green:0.67f blue:0.96f alpha:1.00f];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    self.title = @"正在接单";
    
    //leftBarButtonItem

    
    //rightBarButtonItem
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"newphone"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarClick)];
    [rightBar setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    //table初始化
    self.WorkListTabelView.delegate = self;
    self.WorkListTabelView.dataSource = self;
    self.WorkListTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak __typeof(self)weakSelf = self;
    //上拉加载更多
    footerView = [self.WorkListTabelView addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf loadMoreAction];
    }];
    
    headerView = [self.WorkListTabelView addHeaderWithRefreshHandler:^(FCXRefreshBaseView *refreshView){
        
        [weakSelf loadData];
    }];
    
    self.HomeView.backgroundColor = [UIColor whiteColor];
    
    //自动刷新
    footerView.autoLoadMore = NO;

}
/**apper首界面 */
-(void)apperInitHomeView
{
    
    
    DataArray = [[NSMutableArray alloc]init];
    Pages = 1;
    //登录之后从其他界面切换过来
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
   // NSString *loginStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    //NSString *PassWordStr = [userDefaultes objectForKey:@"PassWord"];
    if (isloginidStr.length < 1) {
        self.LandedView.hidden = NO;
        
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        return;
    }
    
    if (isloginidStr.length > 0) {
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        NSInteger year = [dateComponent year];
        NSInteger month = [dateComponent month];
        if (month > 11 || year == 2016) {
//            [self.view makeToast:@"软件失效!"];
//            self.LandedView.hidden = NO;
//            self.navigationController.navigationBarHidden = YES;
//            self.tabBarController.tabBar.hidden = YES;
//            return;
        }

        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.LandedView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.tabBarController.tabBar.hidden = NO;
//        NSMutableDictionary *postDicFirst  = [[NSMutableDictionary alloc]init];
//        //测试账号  qw108077 123456
//        [postDicFirst setObject:guserStr forKey:@"guser"];
//        [postDicFirst setObject:PassWordStr forKey:@"gpassword"];
//        [postDicFirst setObject:APPKey forKey:@"key"];
//        //服务器给的域名
//        NSString *domainStrFirst = [NSString stringWithFormat:@"%@%@",BaseUrl,@"xcglogin"];
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        AFHTTPRequestOperationManager *managerFirst = [AFHTTPRequestOperationManager manager];
//        managerFirst.responseSerializer = [AFHTTPResponseSerializer serializer];
//        [managerFirst POST:domainStrFirst parameters:postDicFirst success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //json解析
//            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//            if (resultDic.count > 0) {
//                NSInteger resStr = [[resultDic objectForKey:@"res"] integerValue];
//                /*
//                 阶段一
//                 判断结果 成功 识别
//                 成功解析存储 guser 洗车工工号 isloginid 随机ID
//                 失败 --弹出框
//                 */
//                switch (resStr) {
//                    case 1:
//                    {
//                        [self.view makeToast:@"该账号不存在!"];
//                        [MBProgressHUD hideHUDForView:self.view animated:YES];
//                        return ;
//                    }
//                        break;
//                    case 2:
//                    {
//                        [self.view makeToast:@"密码错误!"];
//                        [MBProgressHUD hideHUDForView:self.view animated:YES];
//                        return ;
//                    }
//                        break;
//                    case 3:
//                    {
                        //请洗车工个人信息
                        NSMutableDictionary *postDic3  = [[NSMutableDictionary alloc]init];
                        [postDic3 setObject:guserStr forKey:@"guser"];
                        [postDic3 setObject:isloginidStr forKey:@"isloginid"];
                        [postDic3 setObject:APPKey forKey:@"key"];
                        //服务器给的域名
                        NSString *domainStr3 = [NSString stringWithFormat:@"%@%@",BaseUrl,@"grxx"];
                        AFHTTPRequestOperationManager *manager3 = [AFHTTPRequestOperationManager manager];
                        manager3.responseSerializer = [AFHTTPResponseSerializer serializer];
                        [manager3 POST:domainStr3 parameters:postDic3 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            //json解析
                            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                            NSLog(@"ge------%@",resultDic);
                            if (resultDic.count > 0) {
                                NSDictionary *dataDic = [resultDic objectForKey:@"grxx"];
                                if ([dataDic isKindOfClass:[NSNull class]] ) {
                                    [self.view makeToast:@"网络异常，请保持网络环境良好!"];
                                    return ;
                                }
                                self.NameLabel.text = [dataDic objectForKey:@"gname"];
                                self.JobNumberLabel.text = [dataDic objectForKey:@"guser"];
                                NSString *imageURLStr = [dataDic objectForKey:@"gpicture"];
                                [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,imageURLStr]] placeholderImage:[UIImage imageNamed:@"headerImg"]];
                                
                                //存储头像 姓名 身份证号  手机号码
                                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                                
                                NSString *HeaderURL = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gpicture"]];
                                if ([HeaderURL isKindOfClass:[NSNull class]]) {
                                    HeaderURL = nil;
                                }
                                NSString *UserName = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gname"]];
                                NSString *IdentityStr = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"sfz"]];
                                NSString *IphoneNumStr = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"gphone"]];
                                
                                [userDefaultes setObject:HeaderURL forKey:@"HeaderURL"];
                                [userDefaultes setObject:UserName forKey:@"UserName"];
                                [userDefaultes setObject:IdentityStr forKey:@"IdentityStr"];
                                [userDefaultes setObject:IphoneNumStr forKey:@"IphoneNumStr"];
                                [userDefaultes synchronize];
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
                        
                        
                        
                        
                        NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
                        [postDics setObject:guserStr forKey:@"guser"];
                        [postDics setObject:isloginidStr forKey:@"isloginid"];
                        [postDics setObject:@"1" forKey:@"page"];
                        [postDics setObject:APPKey forKey:@"key"];
                        
                        //服务器给的域名
                        NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"jdlb"];
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                        [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            //json解析
                            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                            if (resultDic.count > 0) {
                                DataArray = [resultDic objectForKey:@"list"];
                                if ([DataArray isKindOfClass:[NSNull class]]) {
                                    [self.view makeToast:@"没有订单!"];
                                    DataArray = [[NSMutableArray alloc]init];
                                    return ;
                                }
                                
                                _ddym = [[resultDic objectForKey:@"ddym"] intValue];
                                if (_ddym == 1) {
                                    _ddymButton.backgroundColor = RGBCOLOR(73, 180, 252);;
                                    _ddymButton.userInteractionEnabled = YES;
                                }
                                else if (_ddym == 2) {
                                    _ddymButton.backgroundColor = [UIColor lightGrayColor];
                                    _ddymButton.userInteractionEnabled = NO;
                                }
                                
                                //数组排序 DataArray数组里个数必须大于0
//                                NSMutableArray *copDataArray = [NSMutableArray arrayWithArray:DataArray];;
//                                NSMutableArray *CpArray = [[NSMutableArray alloc]init];
//                                for (NSDictionary *dic in DataArray) {
//                                    if ([[dic objectForKey:@"methods"]isEqualToString:@"内外全洗"]) {
//                                        [CpArray addObject:dic];
//                                        NSUInteger index = [DataArray indexOfObject:dic];
//                                        [copDataArray removeObjectAtIndex:index];
//                                    }
//                                }
//                                [CpArray addObjectsFromArray:copDataArray];
//                                NSMutableArray *arr = [self ArrayCompare:CpArray];
//                                DataArray = [NSMutableArray arrayWithArray:arr];
                                [self.WorkListTabelView reloadData];
                            }
                            else
                            {
                                [self.view makeToast:@"服务器出错,请联系我们!"];
                            }
                            
                        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                            [self.view makeToast:@"网络异常,请检测网络!"];
                        }];
                    
                        
//                    }
//                        break;
//                        
//                    case 5:
//                    {
//                        [MBProgressHUD hideHUDForView:self.view animated:YES];
//                        [self.view makeToast:@"该账号已在其他手机上登录!"];
//                        self.LandedView.hidden = NO;
//                        self.navigationController.navigationBarHidden = YES;
//                        self.tabBarController.tabBar.hidden = YES;
//                        return ;
//                    }
//                        break;
//                    default:
//                        break;
//                }
//            }
//            else
//            {
//                [self.view makeToast:@"服务器出错,请联系我们!"];
//            }
//        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
//            [self.view makeToast:@"网络异常,请检测网络!"];
//        }];
        
    }
    
    
}
#pragma mark------------------------UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return DataArray.count;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TCellID";
    HomeTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"HomeTableViewCell" owner:self options:nil]lastObject];
        
    }
    if (DataArray.count == 0) {
        return cell;
    }
    NSMutableDictionary *listDic = [DataArray objectAtIndex:indexPath.row];
   
    cell.LicensePlateLabel.text = [NSString stringWithFormat:@"车牌号：%@",[listDic objectForKey:@"carnumber"]];
   // NSLog(@"cell剩余时间--%@",[listDic objectForKey:@"gqtime"]);
    cell.CountdownTime = [NSString stringWithFormat:@"%@",[listDic objectForKey:@"gqtime"]];
    cell.delegate = self;
    cell.TimeLabel.text = [NSString stringWithFormat:@"下单地址：%@",[listDic objectForKey:@"fwwd"]];
   
    NSString *bzStr = [NSString stringWithFormat:@"%@",[listDic objectForKey:@"remark"]];
    //NSLog(@"备注信息——----%@",bzStr);
    if (bzStr.length > 0) {
        cell.OrderMarkLabel.text = [NSString stringWithFormat:@"备注信息：%@",bzStr];
    }
    else
    {
        cell.OrderMarkLabel.text = @"备注信息：暂无";
    }
    [cell.OrderMarkLabel sizeToFit];
    [cell.containerVIew sizeToFit];
    //cell.OrderMarkLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if ([[listDic objectForKey:@"methods"]isEqualToString:@"内外全洗"]) {
         cell.OrderView.backgroundColor = [UIColor colorWithRed:1.00f green:0.59f blue:0.06f alpha:1.00f];
    }
    cell.SVC = self;
    cell.UID =  [listDic objectForKey:@"id"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
#pragma makr-------------完成订单 刷新列表
-(void)CompletionOfOrders
{
    //[self apperInitHomeView];

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =  [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    DLog(@"cell.backgroundView.frame.size.height:%f",cell.contentView.frame.size.height);
    return cell.contentView.frame.size.height;
    

}
#pragma mark---------------------------上拉刷新
- (void)loadMoreAction {
    __weak UITableView *weakTableView = self.WorkListTabelView;
    __weak FCXRefreshFooterView *weakFooterView = footerView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

              //刷新事件
        
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *guserStr = [userDefaultes objectForKey:@"guser"];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        
        NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
        [postDics setObject:guserStr forKey:@"guser"];
        [postDics setObject:isloginidStr forKey:@"isloginid"];
        [postDics setObject:[NSString stringWithFormat:@"%ld",(long)Pages + 1] forKey:@"page"];
        [postDics setObject:APPKey forKey:@"key"];
        
        //服务器给的域名
        NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"jdlb"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //json解析
            [weakFooterView endRefresh];
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"加载更多接单列表-----:%@",resultDic);
            if (resultDic.count > 0) {
                NSMutableArray *TemporaryArray = [resultDic objectForKey:@"list"];
                if ([TemporaryArray isKindOfClass:[NSNull class]]) {
                    [self.view makeToast:@"没有新的订单!"];
                    [weakTableView reloadData];
                    
                    
                    return ;
                }
                
                if (TemporaryArray.count > 0) {
                    Pages++;
                }
                
                _ddym = [[resultDic objectForKey:@"ddym"] intValue];
                if (_ddym == 1) {
                    _ddymButton.backgroundColor = RGBCOLOR(73, 180, 252);;
                    _ddymButton.userInteractionEnabled = YES;
                }
                else if (_ddym == 2) {
                    _ddymButton.backgroundColor = [UIColor lightGrayColor];
                    _ddymButton.userInteractionEnabled = NO;
                }
                
                //为数据源添加刷新得到的元素
                NSMutableArray *copyArr = [NSMutableArray arrayWithArray:DataArray];
                [copyArr addObjectsFromArray:TemporaryArray];
                DataArray =  [NSMutableArray arrayWithArray:copyArr];
                [weakTableView reloadData];
            }
            else
            {
                [self.view makeToast:@"服务器出错,请联系我们!"];
            }
            
        } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
            [self.view makeToast:@"网络异常,请检测网络!"];
        }];

        
        
        
    });
}
#pragma mark---------------------------下拉刷新
-(void)loadData
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak FCXRefreshHeaderView *weakHeaderView = headerView;
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
    [postDics setObject:guserStr forKey:@"guser"];
    [postDics setObject:isloginidStr forKey:@"isloginid"];
    [postDics setObject:@"1" forKey:@"page"];
    [postDics setObject:APPKey forKey:@"key"];
    
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"jdlb"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakHeaderView endRefresh];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            DataArray = [resultDic objectForKey:@"list"];
            if ([DataArray isKindOfClass:[NSNull class]]) {
                [self.view makeToast:@"没有订单!"];
                DataArray = [[NSMutableArray alloc]init];
//                [self.WorkListTabelView reloadData];
                
                
                return ;
            }
            _ddym = [[resultDic objectForKey:@"ddym"] intValue];
            if (_ddym == 1) {
                _ddymButton.backgroundColor = RGBCOLOR(73, 180, 252);;
                _ddymButton.userInteractionEnabled = YES;
            }
            else if (_ddym == 2) {
                _ddymButton.backgroundColor = [UIColor lightGrayColor];
                _ddymButton.userInteractionEnabled = NO;
            }
            [self.WorkListTabelView reloadData];
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {\
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view makeToast:@"网络异常,请检测网络!"];
    }];
}

#pragma mark --圆角一刀切
-(void)setImageForcornerRadius:(UIImageView *)ImageView BoardWidth:(CGFloat )boardWidth
{
    if ([UIScreen mainScreen].bounds.size.width == 414) {
        ImageView.layer.cornerRadius = ImageView.bounds.size.height/2+13;
    }else if ([UIScreen mainScreen].bounds.size.width == 375)
    {
        ImageView.layer.cornerRadius = ImageView.bounds.size.height/2+8;
    }
    else
    {
        ImageView.layer.cornerRadius = ImageView.bounds.size.height/2;
    }
    if (boardWidth != 0) {
        [ImageView.layer setBorderWidth:boardWidth];
        [ImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    
}

#pragma mark---------TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//}

#pragma mark textfiled-delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.LandedView.hidden == YES) {
        return;
    }
    
        CGRect frame = textField.frame;
        int offset = frame.origin.y + 350 - (self.view.frame.size.height - 216.0);//键盘高度216
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0)
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1513) {
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark---- 时间戳


@end
