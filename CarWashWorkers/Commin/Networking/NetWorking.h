//
//  NetWorking.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/9/7.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorking : NSObject
+(NetWorking *)Ant;
#pragma mark ----普通接口
-(NSMutableDictionary *)PostKeyDic:(NSMutableDictionary *)parametersDic MethodName:(NSString *)MethodName;
#pragma mark ----图片接口
-(NSMutableDictionary *)PostkeyDic:(NSMutableDictionary *)parametersDic ImageDataArray:(NSMutableArray *)ImgDataArray MethodName:(NSString *)MethodName;
@end
