//
//  FirstTableViewCell.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/18.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "FirstTableViewCell.h"
#import "CarWashWorkers.pch"

@implementation FirstTableViewCell
{
    /**选择照片提示框 */
    UIActionSheet *myActionSheet;
    /**缓存图片路径Array */
    NSMutableDictionary *postImageDic;
    /**是否开始洗车 */
    BOOL IsStartWash;
    
//    /**存储图片DataArray */
//    NSMutableArray  *dataImgArray;
    

    
  

}
- (void)awakeFromNib {
    // Initialization code
#pragma mark --内容view增加边框
    UIColor *whiteClocor = [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
    [self.contView.layer setBorderWidth:0.8f];
    [self.contView.layer setBorderColor:whiteClocor.CGColor];
    self.contView.layer.cornerRadius = 5.0f;
    _dataImgArray = [[NSMutableArray alloc]init];
    _ImgNameArray = [[NSMutableArray alloc]init];
    
    _btnImageDic = [NSMutableDictionary dictionary];
    
    //增加收拾
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1Click)];
    [self.FirstImageView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2Click)];
    [self.SecondImageView addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap3Click)];
    [self.ThirdImageView addGestureRecognizer:tap3];
    
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap4Click)];
    [self.FourImageView addGestureRecognizer:tap4];

    
}

-(void)tap1Click
{
    if (self.FirstImageView.image) {
        [imageBig
         showImage:self.FirstImageView];
    }
    
   
}
-(void)tap2Click
{
    if (self.SecondImageView.image) {
        [imageBig
         showImage:self.SecondImageView];
    }
    
}
-(void)tap3Click
{
    if (self.ThirdImageView.image) {
        [imageBig
         showImage:self.ThirdImageView];
    }
   
}
-(void)tap4Click
{
    if (self.FourImageView.image) {
        [imageBig
         showImage:self.FourImageView];
    }
   
}



#pragma mark-----------第一页
//搜索
- (IBAction)SearchBtnClick:(UIButton *)sender {
    
}
//订单转让
- (IBAction)TransferFBtnClick:(UIButton *)sender {
//    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
//    [userDefaultes setObject:self.UID forKey:@"ID"];
////    [userDefaultes objectForKey:@"ID"];
//    [userDefaultes synchronize];
//    self.ConfirmTransferView.hidden = NO;
//    self.backGVC.tabBarController.tabBar.hidden =  YES;
//    self.backGVC.navigationController.navigationBarHidden = YES;
//    [self.OutTabView reloadData];
    [GlobalVar sharedSingleton].DDID = self.UID;
    if (_tranferBlock != nil) {
        _tranferBlock();
    }
    
}
//开始洗车
- (IBAction)StartWashBtnClick:(UIButton *)sender {
    
    if ([self.payStatus isEqualToString:@"0"]) {
        [self.backGVC.view makeToast:@"该订单未支付!"];
        return;
    }
    
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:self.UID forKey:@"id"];
//    [postDic setObject:@"1" forKey:@"page"];
    [postDic setObject:APPKey forKey:@"key"];
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"ksxc"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"点击接受订单------%@",resultDic);
        if (resultDic.count > 0) {
            NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
            switch (res) {
                case 1:
                {
                    //翻页效果动画 右边
                    CATransition *animation = [CATransition animation];
                    animation.delegate = self;
                    animation.duration = 1.f;
                    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                    animation.type = kCATransitionFade;
                    self.ContainViewF.hidden = YES;
                    [self.ContainViewF.layer addAnimation:animation forKey:@"animation"];
                    self.TransferBtn.userInteractionEnabled = NO;
                    [self.TransferBtn setBackgroundColor:[UIColor grayColor]];
                    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                    if ([userDefaultes objectForKey:@"UIDArray"]) {
                        NSMutableArray *UIDArray =  [[userDefaultes objectForKey:@"UIDArray"] mutableCopy];
                        if (![UIDArray containsObject:self.UID]) {
                            [UIDArray addObject:self.UID];
                            [userDefaultes setObject:UIDArray forKey:@"UIDArray"];
                            [userDefaultes synchronize];
                        }
                    }
                    else
                    {
                        NSMutableArray *UIDArray  = [[NSMutableArray alloc]init];
                        [UIDArray addObject:self.UID];
                        [userDefaultes setObject:UIDArray forKey:@"UIDArray"];
                        [userDefaultes synchronize];
                    }
                    
                }
                    break;
                case 2:
                {
                    
                    if ([self.judgeStrzt isEqualToString:@"1"]) {
                       // [self.contentView makeToast:@"此单为已接订单!"];
                        CATransition *animation = [CATransition animation];
                        animation.delegate = self;
                        animation.duration = 1.f;
                        animation.timingFunction = UIViewAnimationCurveEaseInOut;
                        animation.type = kCATransitionFade;
                        self.ContainViewF.hidden = YES;
                        [self.ContainViewF.layer addAnimation:animation forKey:@"animation"];
                        self.TransferBtn.userInteractionEnabled = NO;
                        [self.TransferBtn setBackgroundColor:[UIColor grayColor]];
                        
                    }
                    else if ([self.judgeStrzt isEqualToString:@"3"])
                    {
                        [self.contentView makeToast:@"此单为已退订单!"];
                    }
                    else if ([self.judgeStrzt isEqualToString:@"4"])
                    {
                        [self.contentView makeToast:@"此单为已完成订单!"];
                    }
                    else
                    {
                         [self.contentView makeToast:@"网络异常!"];
                    }
                    
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



#pragma mark-----------第二页
//联系车主
- (IBAction)ContactBtn:(UIButton *)sender {
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.userID];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.backGVC.view addSubview:callWebview];
  
    
    
}
//获取图片
- (IBAction)FirstImgBtnClick:(UIButton *)sender {
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    myActionSheet.tag = sender.tag;
    [myActionSheet showInView:self.backGVC.view];
}
- (IBAction)SecondImgBtnClick:(UIButton *)sender {
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    myActionSheet.tag = sender.tag;
    [myActionSheet showInView:self.backGVC.view];
}
- (IBAction)ThirdImgBtnClick:(UIButton *)sender {
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    myActionSheet.tag = sender.tag;
    [myActionSheet showInView:self.backGVC.view];
}
- (IBAction)FourImgBtnClick:(UIButton *)sender {
    myActionSheet = [[UIActionSheet alloc]
                     initWithTitle:nil
                     delegate:self
                     cancelButtonTitle:@"取消"
                     destructiveButtonTitle:nil
                     otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    myActionSheet.tag = sender.tag;
    [myActionSheet showInView:self.backGVC.view];
}
//订单转让
- (IBAction)TransferBtnClick:(UIButton *)sender {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:self.UID forKey:@"ID"];
    [userDefaultes synchronize];
    self.backGVC.tabBarController.tabBar.hidden =  YES;
    self.backGVC.navigationController.navigationBarHidden = YES;
    self.ConfirmTransferView.hidden = NO;
    [self.OutTabView reloadData];
  
}
//确定完成
- (IBAction)SureBtnClick:(UIButton *)sender {
    
    if(_dataImgArray.count < 1)
    {
        [self.backGVC.view makeToast:@"请上传图片"];
        return ;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"洗车备注" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
    
}
-(void)alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (_dataImgArray.count < 1 ){
        [self.backGVC.view makeToast:@"请添加图片"];
    }
    
    //得到输入框
    UITextField *tf=[alertView textFieldAtIndex:0];
    NSString *BZStr;
    if (tf.text.length < 1) {
        BZStr = @"备注";
    }
    else
    {
        BZStr = tf.text;
    }
    NSLog(@"完成洗车备注---%@,UID---%@",BZStr,self.UID);
    [self.backGVC.view makeToastActivity];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
    NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
    
    NSMutableDictionary *postDic  = [[NSMutableDictionary alloc]init];
    [postDic setObject:guserStr forKey:@"guser"];
    [postDic setObject:isloginidStr forKey:@"isloginid"];
    [postDic setObject:self.UID forKey:@"id"];
    [postDic setObject:BZStr forKey:@"bz"];
    [postDic setObject:APPKey forKey:@"key"];
    
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,@"wcxc"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //如果还需要上传其他的参数，参考上面的POST请求，创建一个可变字典，存入需要提交的参数内容，作为parameters的参数提交
    [manager POST:domainStr parameters:postDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         //_imageArray就是图片数组，我的_imageArray里面存的都是图片的data，下面可以直接取出来使用，如果存的是image，将image转换data的方法如下：NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
         if (_dataImgArray.count > 0 ){
             for(int i = 0;i < _dataImgArray.count;i ++){
                 NSData *data=_dataImgArray[i];
                 //上传的参数名
                 NSString *name = @"urlname[]";
                 
                 NSString * morelocationString = [_ImgNameArray objectAtIndex:i];
                 
                 //上传的filename
                 NSString *fileName = [NSString stringWithFormat:@"%@.jpg",morelocationString];
                 [formData appendPartWithFileData:data
                                             name:name
                                         fileName:fileName
                                         mimeType:@"image/jpeg"];
             }
         }
        
         
     }success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         [self.backGVC.view hideToastActivity];
         //json解析
         NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         if (resultDic.count > 0) {
             NSInteger res = [[resultDic objectForKey:@"res"] integerValue];
             if (res == 1) {
                 [self.backGVC.view makeToast:@"提交成功!"];
                 [_delegate CompletionOfOrders];
             }
             else
             {
                 [self.backGVC.view makeToast:@"提交失败!"];
                 
             }
         }
         else
         {
             [self.backGVC.view makeToast:@"网络异常"];
             
         }
         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              // 解析失败
              [self.backGVC.view hideToastActivity];
              [self.backGVC.view makeToast:@"网络异常!"];
          }];
    
}




#pragma mark--------------------------------获取图片
#pragma mark---------------------------获取系统相册或者照相机的照片
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
        [_backGVC presentViewController:picker animated:YES completion:nil];
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
    [self.backGVC presentViewController:picker animated:YES completion:nil];
    
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
        imagesize.height =400;
        imagesize.width =400;
        UIImage *imageNew = [self imageWithImage:image scaledToSize:imagesize];
        NSData *minDate = UIImageJPEGRepresentation(imageNew, 1);
        
        NSDate * senddate=[NSDate date];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
        NSString * morelocationString=[dateformatter stringFromDate:senddate];
        
        if (myActionSheet.tag == 1000) {
            if (_dataImgArray.count == 0) {
               [_dataImgArray addObject:minDate];
                [_ImgNameArray addObject:morelocationString];
            }
            else {
                [_dataImgArray replaceObjectAtIndex:0 withObject:minDate];
                [_ImgNameArray replaceObjectAtIndex:0 withObject:morelocationString];
            }
        }
        else {
            [_dataImgArray addObject:minDate];
            [_ImgNameArray addObject:morelocationString];
        }
      
        
        UIButton *btn = (UIButton *)[self.ContainViewS viewWithTag:myActionSheet.tag];
        [btn setBackgroundImage:imageNew forState:UIControlStateNormal];
        [btn setBackgroundImage:imageNew forState:UIControlStateHighlighted];
        if (6000-myActionSheet.tag <= 0) {
            return;
        }
        UIButton *btn2 = (UIButton *)[self.ContainViewS viewWithTag:myActionSheet.tag+1000];
        btn2.hidden = NO;
        NSLog(@"图片字典---:%@",postImageDic);
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
