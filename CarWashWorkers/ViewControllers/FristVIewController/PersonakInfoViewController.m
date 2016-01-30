//
//  PersonakInfoViewController.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/10/8.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "PersonakInfoViewController.h"
#import "ChangePasswordViewController.h"
@interface PersonakInfoViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    /** 是否抬起TextField */
    BOOL IsUP;
    /** 选择照片提示框 */
    UIActionSheet *myActionSheet;
    /** 缓存图片路径Array */
    NSMutableDictionary *postImageDic;
    /** 存储图片DataArray */
    NSMutableArray  *dataImgArray;
    
    NSTimer *timer;
    
}
@end

@implementation PersonakInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    IsUP = YES;
    postImageDic  = [[NSMutableDictionary alloc]init];
    dataImgArray  = [[NSMutableArray alloc]init];
    self.tabBarController.tabBar.hidden = YES;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    /*
     头像view
    HeaderImgView;
     头像
    HeaderImage;
     
     用户姓名view
    UserNameVIew;
    UserNameFiled;

     身份证号view
    IdentityView;
    IdentityField;
    
     手机号码view
    IphoneNumView;
    IphoneNumField;
    
     修改密码view
    ModifyPassView;
    ModifyBtn;
    
    
     确认编辑Btn
    SureEditorBtn;
    
    退出登录Btn
    SignOutBtn;
     */
    [super viewDidLoad];
    //边框 圆角
    [self.HeaderImgView.layer setBorderWidth:1.0f];
    [self.HeaderImgView.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    [self.HeaderImgView.layer setCornerRadius:3.0f];
    
    [self.UserNameVIew.layer setBorderWidth:1.0f];
    [self.UserNameVIew.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    [self.UserNameVIew.layer setCornerRadius:3.0f];
    
    [self.IdentityView.layer setBorderWidth:1.0f];
    [self.IdentityView.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    [self.IdentityView.layer setCornerRadius:3.0f];
    
    [self.IphoneNumView.layer setBorderWidth:1.0f];
    [self.IphoneNumView.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    [self.IphoneNumView.layer setCornerRadius:3.0f];
    
    [self.ModifyPassView.layer setBorderWidth:1.0f];
    [self.ModifyPassView.layer setBorderColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f].CGColor];
    [self.ModifyPassView.layer setCornerRadius:3.0f];
    
    [self.SureEditorBtn.layer setCornerRadius:3.0f];
    [self.SignOutBtn.layer setCornerRadius:3.0f];
    
    self.HeaderImage.layer.masksToBounds = YES;
    [self.HeaderImage.layer setBorderWidth:5.0f];
    [self.HeaderImage.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.HeaderImage.layer setCornerRadius:29.0f];
    
    //标题 返回按钮
    self.title  =@"信息编辑";
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon-btn011"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClick)];
    leftBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBar;
    
    //UITextFieldDelegate
    self.UserNameFiled.delegate  = self;
    self.IdentityField.delegate  = self;
    self.IphoneNumField.delegate  = self;
    
    //上传头像
    UITapGestureRecognizer *tapSele = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectImg)];
    [self.HeaderImage addGestureRecognizer:tapSele];
    
    //读取个人消息赋值
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *HeaderURL = [userDefaultes objectForKey:@"HeaderURL"];
    NSString *UserNameStr = [userDefaultes objectForKey:@"UserName"];
    NSString *IdentityStr = [userDefaultes objectForKey:@"IdentityStr"];
    NSString *IphoneNumStr = [userDefaultes objectForKey:@"IphoneNumStr"];
    if (HeaderURL.length > 0) {
        [self.HeaderImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DownLoadImgUrl,HeaderURL]] placeholderImage:[UIImage imageNamed:@"headerImg"]];
    }
    else
    {
        [self.HeaderImage setImage:[UIImage imageNamed:@"headerImg"]];
    
    }
    if (UserNameStr.length > 0) {
        self.UserNameFiled.text = UserNameStr;
    }
    else
    {
        self.UserNameFiled.text = @"请输入姓名";
    }
    
    if (IdentityStr.length > 0) {
       self.IdentityField.text = IdentityStr;
    }
    else
    {
        self.IdentityField.text = @"请输入身份证号码";
        
    }
    if (IphoneNumStr.length > 0) {
       self.IphoneNumField.text = IphoneNumStr;
    }
    else
    {
        self.IphoneNumField.text = @"请输入手机号码";
        
    }
    
}
#pragma mark - *********************************************点击事件区
//上传头像
-(void)selectImg
{
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    [myActionSheet showInView:self.view];
}
//返回
-(void)goBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
//修改密码
- (IBAction)ChangePasswordClick:(UIButton *)sender {
    ChangePasswordViewController *cpVC = [[ChangePasswordViewController alloc]init];
    [self.navigationController pushViewController:cpVC animated:YES];
}
//确定编辑
- (IBAction)SureEditorBtnClick:(UIButton *)sender {
    
    /*
     判断
     网络请求
     */
    if (self.UserNameFiled.text.length < 1) {
        [self.view makeToast:@"姓名不可为空"];
        return;
    }
    if (self.IdentityField.text.length < 1) {
        [self.view makeToast:@"身份证号不可为空"];
        return;
    }
    else if (self.IdentityField.text.length != 18)
    {
        [self.view makeToast:@"请输入正确的身份证号码"];
        return;
    }
    if ([self checkTel:self.IphoneNumField.text] == NO) {
        return;
    }
    
    [self.view makeToastActivity];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *loginStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
    [postDics setObject:guserStr forKey:@"guser"];
    [postDics setObject:loginStr forKey:@"isloginid"];
    [postDics setObject:self.UserNameFiled.text forKey:@"gname"];
    [postDics setObject:self.IphoneNumField.text forKey:@"gphone"];
    [postDics setObject:self.IdentityField.text forKey:@"sfz"];
    [postDics setObject:APPKey forKey:@"key"];
    
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"gexxbj"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            if (res == 1) {
                [self.view makeToast:@"个人信息编辑成功!"];
                
                timer = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
            }
            else
            {
                [self.view makeToast:@"个人信息编辑失败!"];
                
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

-(void)timerFired
{
    [self.navigationController popViewControllerAnimated:YES];
    [timer invalidate];
    timer = nil;
}
//退出登录
- (IBAction)SignOutBtnClick:(UIButton *)sender {
    
    [self.view makeToastActivity];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *loginStr = [userDefaultes objectForKey:@"isloginid"];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSMutableDictionary *postDics  = [[NSMutableDictionary alloc]init];
    [postDics setObject:guserStr forKey:@"guser"];
    [postDics setObject:loginStr forKey:@"isloginid"];
    [postDics setObject:APPKey forKey:@"key"];
    
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"xcgquitlogin"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDics success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.view hideToastActivity];
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            if (res == 1) {
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes removeObjectForKey:@"isloginid"];
                [userDefaultes removeObjectForKey:@"guser"];
                [userDefaultes removeObjectForKey:@"HeaderURL"];
                [userDefaultes removeObjectForKey:@"UserName"];
                [userDefaultes removeObjectForKey:@"IdentityStr"];
                [userDefaultes removeObjectForKey:@"IphoneNumStr"];
                [self.view makeToast:@"退出登录成功!"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self.view makeToast:@"退出登录失败!"];
                
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

#pragma mark - *********************************************textfiled-delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (IsUP == YES) {
        CGRect frame = textField.frame;
        int offset = frame.origin.y + 350 - (self.view.frame.size.height - 216.0);//键盘高度216
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0)
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        IsUP = NO;
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    IsUP = YES;
    [self.UserNameFiled resignFirstResponder];
    [self.IdentityField resignFirstResponder];
    [self.IphoneNumField resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.UserNameFiled resignFirstResponder];
    [self.IdentityField resignFirstResponder];
    [self.IphoneNumField resignFirstResponder];
     IsUP = YES;
}

#pragma mark--------------------------------获取图片层
#pragma mark---------获取系统相册或者照相机的照片
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == myActionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
        {
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            [userDefaultes setObject:@"YES" forKey:@"Storing"];
            [userDefaultes synchronize];
            [self takePhoto];
        }
            break;
            
        case 1:  //打开本地相册
        {
            NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
            [userDefaultes setObject:@"YES" forKey:@"Storing"];
            [userDefaultes synchronize];
            [self LocalPhoto];
        }
            break;
    }
}

#pragma mark---开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

#pragma mark--- 打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}
#pragma mark---选择图片
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 0.5);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        
#warning -----清理沙盒
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径 -----上传使用
        NSString *filePath;
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //存储路径
        [postImageDic setObject:filePath forKey:[NSString stringWithFormat:@"%ld",(long)myActionSheet.tag]];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        
       
        //添加照片上去 并且让下一个btn显示
        CGSize imagesize = image.size;
        imagesize.height = 200;
        imagesize.width = 200;
        UIImage *imageNew = [self imageWithImage:image scaledToSize:imagesize];
        NSData *newsData  = UIImageJPEGRepresentation(imageNew, 1);
        [dataImgArray addObject:newsData];
        //上传头像
        [self uploadHeaderIMG];
        [self.HeaderImage setImage:imageNew];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark---图片压缩
//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - *********************************************其他层(手机号码验证)
- (BOOL)checkTel:(NSString *)str
{
    if ([str length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"手机号码不能为空" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
        
    }
    
    if (str.length != 11) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }
    
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd]) {
        return YES;
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        return NO;
    }
    
    //return YES;
    
    //1[0-9]{10}
    
    //^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$
    
    //    NSString *regex = @"[0-9]{11}";
    
//    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
//    
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    
//    BOOL isMatch = [pred evaluateWithObject:str];
//    
//    if (!isMatch) {
//        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [alert show];
//        return NO;
//        
//    }
//    return YES;
}

#pragma mark - *********************************************网络请求层
-(void)uploadHeaderIMG
{
    [self.view makeToastActivity];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:APPKey forKey:@"key"];
    //NSLog(@"头像上传参数----%@,-----%@",guserStr,isloginidStr);
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"txbj"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //如果还需要上传其他的参数，参考上面的POST请求，创建一个可变字典，存入需要提交的参数内容，作为parameters的参数提交
    [manager POST:domainStr parameters:postDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         //_imageArray就是图片数组，我的_imageArray里面存的都是图片的data，下面可以直接取出来使用，如果存的是image，将image转换data的方法如下：NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
         if (dataImgArray.count > 0 ){
             for(int i = 0;i < dataImgArray.count;i ++){
                 NSData *data=dataImgArray[i];
                 //上传的参数名
                 NSString *name = @"gpicture";
                 //上传的filename
                 NSString *fileName = [NSString stringWithFormat:@"%@.jpg",name];
                 [formData appendPartWithFileData:data
                                             name:name
                                         fileName:fileName
                                         mimeType:@"image/jpeg"];
             }
         }
         
     }success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         [self.view hideToastActivity];
         //json解析
         NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if (resultDic.count > 0) {
             NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
             if (res == 1) {
                 [self.view makeToast:@"头像上传成功!"];
             }
             else
             {
                 [self.view makeToast:@"头像上传失败!"];
                 
             }
         }
         else
         {
             [self.view makeToast:@"网络异常"];
             
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // 解析失败
              [self.view hideToastActivity];
              [self.view makeToast:@"网络异常!"];
          }];

    
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
