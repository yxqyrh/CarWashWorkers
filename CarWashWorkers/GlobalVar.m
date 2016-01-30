//
//  GlobalVar.m
//  WDLinkUp
//
//  Created by CSB on 15-3-3.
//  Copyright (c) 2015年 Wonders information Co., LTD. All rights reserved.
//

#import "GlobalVar.h"

@implementation GlobalVar


+ (GlobalVar *)sharedSingleton
{
    static GlobalVar *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[GlobalVar alloc] init];
        
        return sharedSingleton;
    }
}


@end