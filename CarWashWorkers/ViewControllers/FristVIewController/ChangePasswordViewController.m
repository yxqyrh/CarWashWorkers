//
//  ChangePasswordViewController.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/10/8.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>
{
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIView *FirstVIew;
@property (weak, nonatomic) IBOutlet UITextField *OldTextField;

@property (weak, nonatomic) IBOutlet UIView *SecodView;
@property (weak, nonatomic) IBOutlet UITextField *NewTestField;

@property (weak, nonatomic) IBOutlet UIButton *OKBtnClick;

@end

@implementation ChangePasswordViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //标题 返回按钮
    self.title  =@"密码修改";
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon-btn011"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClick)];
    leftBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBar;
    //圆角 边框
    [self.FirstVIew.layer setBorderWidth:1.0f];
    [self.FirstVIew.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    
    [self.SecodView.layer setBorderWidth:1.0f];
    [self.SecodView.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
   //UITextFieldDelegate
    self.OldTextField.delegate = self;
    self.NewTestField.delegate = self;
    
}
#pragma mark - *********************************************点击事件区
//返回
-(void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)OKBtnClick:(id)sender {
    if (self.OldTextField.text.length < 1 ) {
        [self.view makeToast:@"旧密码不能为空"];
    }
    if ( self.NewTestField.text.length < 1) {
        [self.view makeToast:@"新密码不能为空"];
    }
    [self.view makeToastActivity];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *loginStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
    [postDics setObject:guserStr forKey:@"guser"];
    [postDics setObject:loginStr forKey:@"isloginid"];
    [postDics setObject:self.OldTextField.text forKey:@"gpassword"];
    [postDics setObject:self.NewTestField.text forKey:@"xgpassword"];
    [postDics setObject:APPKey forKey:@"key"];
    
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"xcgxgmm"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            if (res == 1) {
                [self.view makeToast:@"修改密码成功!"];
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes setObject:self.NewTestField.text forKey:@"PassWord"];
                [userDefaultes synchronize];
                [self.OldTextField resignFirstResponder];
                [self.NewTestField resignFirstResponder];
                timer = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
                
            }
            else if (res == 2)
            {
                [self.view makeToast:@"修改密码失败!"];
                [self.OldTextField resignFirstResponder];
                [self.NewTestField resignFirstResponder];
            }
            else
            {
                [self.view makeToast:@"原密码错误!"];
                [self.OldTextField resignFirstResponder];
                [self.NewTestField resignFirstResponder];
            }
        }
        else
        {
            [self.view makeToast:@"服务器出错,请联系我们!"];
            [self.OldTextField resignFirstResponder];
            [self.NewTestField resignFirstResponder];
        }
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [self.view makeToast:@"网络异常,请检测网络!"];
        [self.OldTextField resignFirstResponder];
        [self.NewTestField resignFirstResponder];
    }];
    
}
-(void)timerFired
{
    [self.navigationController popViewControllerAnimated:YES];
    [timer invalidate];
    timer = nil;
}
#pragma mark - *********************************************textfiled-delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.NewTestField) {
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
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.OldTextField resignFirstResponder];
    [self.NewTestField resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.OldTextField resignFirstResponder];
    [self.NewTestField resignFirstResponder];
   
   
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
