//
//  AppDelegate.h
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/11.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeTuiSdk.h"
//#import "ViewControllers.h"
#define kAppId           @"eK2heo8kQw9eAPvuHubxI6"
#define kAppKey          @"gKe40LOpId5yzzP8mQOK"
#define kAppSecret       @"P494TgYfgn8iSHiG0B7nV1"
@class ViewControllers;
@interface AppDelegate : UIResponder <UIApplicationDelegate,GeTuiSdkDelegate>
{
@private
    UINavigationController *_naviController;
    NSString *_deviceToken;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewControllers *MainVC;

@property (retain, nonatomic) NSString *appKey;
@property (retain, nonatomic) NSString *appSecret;
@property (retain, nonatomic) NSString *appID;
@property (retain, nonatomic) NSString *clientId;
@property (assign, nonatomic) SdkStatus sdkStatus;

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;

+(AppDelegate*) sharedInstance;
@end

