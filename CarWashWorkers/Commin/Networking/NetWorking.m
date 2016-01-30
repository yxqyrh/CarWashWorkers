//
//  NetWorking.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/9/7.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "NetWorking.h"

@implementation NetWorking
{
 NSMutableDictionary *dataDic;
}
static NetWorking *ants =  nil;
+(NetWorking *)Ant
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ants = [[NetWorking alloc]init];
    });
    return ants;
}
-(NSMutableDictionary *)PostKeyDic:(NSMutableDictionary *)parametersDic MethodName:(NSString *)MethodName
{
    //服务器给的域名
    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,MethodName];
    [parametersDic setObject:APPKey forKey:@"key"];
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:domainStr parameters:parametersDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //json解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        dataDic = [NSMutableDictionary dictionaryWithDictionary:resultDic];
        NSLog(@"---获取到的json格式的字典--%@",resultDic);

        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        [dataDic setObject:@"请求失败" forKey:@"AFError"];
    }];
    return dataDic;
}
-(NSMutableDictionary *)PostkeyDic:(NSMutableDictionary *)parametersDic ImageDataArray:(NSMutableArray *)ImgDataArray MethodName:(NSString *)MethodName{

    NSString *domainStr = [NSString stringWithFormat:@"%@%@",BaseUrl,MethodName];
    [parametersDic setObject:APPKey forKey:@"key"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //如果还需要上传其他的参数，参考上面的POST请求，创建一个可变字典，存入需要提交的参数内容，作为parameters的参数提交
    [manager POST:domainStr parameters:parametersDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         //_imageArray就是图片数组，我的_imageArray里面存的都是图片的data，下面可以直接取出来使用，如果存的是image，将image转换data的方法如下：NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
         if (ImgDataArray.count > 0 ){
             for(int i = 0;i < ImgDataArray.count;i ++){
                 NSData *data=ImgDataArray[i];
                 //上传的参数名
                 NSString *name = [NSString stringWithFormat:@"%d",i];
                 //上传的filename
                 NSString *fileName = [NSString stringWithFormat:@"%@.jpg",name];
                 [formData appendPartWithFileData:data
                                             name:name
                                         fileName:fileName
                                         mimeType:@"image/jpeg"];
             }
         }
         
     }
     
    success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         //json解析
         NSDictionary * resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
         dataDic = [NSMutableDictionary dictionaryWithDictionary:resultDic];
         NSLog(@"---resultDic--%@",resultDic);
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [dataDic setObject:@"请求失败" forKey:@"AFError"];
          }];
     return dataDic;
}

@end
