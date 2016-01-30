//
//  GlobalVar.h
//  WDLinkUp
//
//  Created by CSB on 15-3-3.
//  Copyright (c) 2015年 Wonders information Co., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface GlobalVar : NSObject




+ (GlobalVar *)sharedSingleton;


@property (nonatomic)NSString *uid;

@property (nonatomic)NSString *DDID;



// uid=18550031362  Isloginid=14435112502766

@property (nonatomic)NSMutableArray* carInfoList;
@end
