//
//  AppDelegate.m
//  CarWashWorkers
//
//  Created by huangchengqi on 15/8/11.
//  Copyright (c) 2015年 ShiZhi. All rights reserved.
//

#import "AppDelegate.h"
#define NotifyActionKey "NotifyAction"
NSString* const NotificationCategoryIdent  = @"ACTIONABLE";
NSString* const NotificationActionOneIdent = @"ACTION_ONE";
NSString* const NotificationActionTwoIdent = @"ACTION_TWO";

@interface AppDelegate ()
{
    NSString *dives;
}
@end

@implementation AppDelegate
@synthesize MainVC = _MainVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    
    [self startSdkWith:kAppId appKey:kAppKey appSecret:kAppSecret];
    
    // [2]:注册APNS
    
    [self registerRemoteNotification];
    
    // [2-EXT]: 获取启动时收到的APN数据
    
    NSDictionary*message=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (message) {
        
        NSString*payloadMsg = [message objectForKey:@"payload"];
        
        NSString*record = [NSString stringWithFormat:@"[APN]%@,%@",[NSDate date],payloadMsg];
        NSLog(@"record----%@",record);
        
    }
    return YES;
}
#pragma mark - *********************************************个推
- (void)registerRemoteNotification {
    
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //IOS8 新的通知机制category注册
        UIMutableUserNotificationAction *action1;
        action1 = [[UIMutableUserNotificationAction alloc] init];
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"取消"];
        [action1 setIdentifier:NotificationActionOneIdent];
        [action1 setDestructive:NO];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationAction *action2;
        action2 = [[UIMutableUserNotificationAction alloc] init];
        [action2 setActivationMode:UIUserNotificationActivationModeBackground];
        [action2 setTitle:@"回复"];
        [action2 setIdentifier:NotificationActionTwoIdent];
        [action2 setDestructive:NO];
        [action2 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *actionCategory;
        actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier:NotificationCategoryIdent];
        [actionCategory setActions:@[action1, action2]
                        forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories = [NSSet setWithObject:actionCategory];
        UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                        UIUserNotificationTypeSound|
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        //        [action1 release];
        //        [action2 release];
        //        [actionCategory release];
        
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|
                                                                       UIRemoteNotificationTypeSound|
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|
                                                                   UIRemoteNotificationTypeSound|
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

#pragma mark - ***********设置地理围栏功能
- (void)startSdkWith:(NSString *)appID appKey:(NSString*)appKey appSecret:(NSString *)appSecret
{
    
    NSError *err =nil;
    
    //[1-1]:通过 AppId、appKey 、appSecret 启动SDK
    
    [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:self error:&err];
    
    //[1-2]:设置是否后台运行开关
    
    [GeTuiSdk runBackgroundEnable:YES];
    
    //[1-3]:设置地理围栏功能，开启LBS定位服务和是否允许SDK 弹出用户定位请求，请求NSLocationAlwaysUsageDescription权限,如果UserVerify设置为NO，需第三方负责提示用户定位授权。
    
    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    
    
    if (err) {
        //        [_viewController logMsg:[NSString stringWithFormat:@"%@", [err localizedDescription]]];
        NSLog(@"%@------",[err localizedDescription]);
    }
}
#pragma mark - ***********[3]:向个推服务器注册deviceToken
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken

{
    NSString *token = [[deviceToken description]
                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    
    dives = [token stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    NSLog(@"deviceTokenssssssssssss--:%@",_deviceToken);
    
    [GeTuiSdk registerDeviceToken:_deviceToken];
    
}
#pragma mark - ***********3-EXT]:如果APNS注册失败，通知个推服务器
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
   
    [GeTuiSdk registerDeviceToken:@""];
}

#pragma mark - ***********支持APP后台刷新数据，会回调performFetchWithCompletionHandler接口
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [GeTuiSdk resume];  // 恢复个推SDK运行
    
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}
#pragma mark - ***********SDK 返回clientid
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId  // SDK 返回clientid

{
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    if (_deviceToken) {
        
        [GeTuiSdk registerDeviceToken:_deviceToken];
        
    }
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:clientId forKey:@"clientId"];
    
    [userDefaultes synchronize];
    

    NSLog(@"注册成功返回Clientid-----%@,deviceToken----%@",clientId,_deviceToken);
}
#pragma mark - ***********收到个推消息
-(void)GeTuiSdkDidReceivePayload:(NSString*)payloadId andTaskId:(NSString*)taskId andMessageId:(NSString *)aMsgId fromApplication:(NSString *)appId
{

    NSData* payload = [GeTuiSdk retrivePayloadById:payloadId]; //根据 payloadId 取回 Payload NSString *payloadMsg = nil;
    if (payload) {
        NSString *payloadMsg;
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length encoding:NSUTF8StringEncoding];
        
 
        
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *isloginidStr = [userDefaultes objectForKey:@"isloginid"];
        if (isloginidStr.length > 0) {
            
        
            if ([payloadMsg isEqualToString:@"{res=1}"]) {
                
                UIViewController *result = nil;
                
                UIWindow * window = [[UIApplication sharedApplication] keyWindow];
                if (window.windowLevel != UIWindowLevelNormal)
                {
                    NSArray *windows = [[UIApplication sharedApplication] windows];
                    for(UIWindow * tmpWin in windows)
                    {
                        if (tmpWin.windowLevel == UIWindowLevelNormal)
                        {
                            window = tmpWin;
                            break;
                        }
                    }
                }
                
                UIView *frontView = [[window subviews] objectAtIndex:0];
                id nextResponder = [frontView nextResponder];
                
                
                
                if ([nextResponder isKindOfClass:[UIViewController class]])
                {
                    result = nextResponder;
                }
                else
                {
                    result = window.rootViewController;
                }
                if ([result isEqual:_MainVC]) {
                    //            ViewControllers *mainvc  = (ViewControllers *)result;
                    //            [mainvc ]
                    [result viewWillAppear:YES];
                }
                
                if ([result isKindOfClass:[UITabBarController class]]) {
                    
                    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                    NSString *guserStr = [userDefaultes objectForKey:@"guser"];
                    if (guserStr.length > 0) {
                        UITabBarController * TbVC = (UITabBarController *)result;
                        [TbVC setSelectedIndex:0];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"dingdan" object:nil];
                    }
                }
            }
        }
        NSLog(@"收到个推消息-----%@",payloadMsg);
        
    }
    
    /*
     接收通知后页面跳转
     
     
     */
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSString *alert;
    @try {
        alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    }
    @catch (NSException *exception) {
        NSLog(@"exception name-----%@",[exception name]);
    }
    @finally {
        //        if (application.applicationState == UIApplicationStateActive) {
        //            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"号令"
        //                                                                message:alert
        //                                                               delegate:self
        //                                                      cancelButtonTitle:@"好"
        //                                                      otherButtonTitles:nil];
        //            [alertView show];
        
        //}
        
    }
    NSLog(@"后台接收消息-----%@",alert);
    [application setApplicationIconBadgeNumber:0];
    
    [GeTuiSdk resume];  // 恢复个推SDK运行
}

#pragma mark - ***********个推错误报告
- (void)GeTuiSdkDidOccurError:(NSError *)error

{
    
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    
    NSLog(@"错误报告--%@",[NSString
                       stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]);
    
}

#pragma mark - ***********SDK收到sendMessage消息回调
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    
    // [4-EXT]:发送上行消息结果反馈
    
    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
    
    NSLog(@"sendMessage回调--%@",record);
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // [EXT] APP进入后台时，通知个推SDK进入后台
    [GeTuiSdk enterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//+(AppDelegate*) sharedInstance{
//    return ((AppDelegate*) [[UIApplication sharedApplication] delegate]);
//}

@end
