//
//  InternetTool.m
//  JerryBeautyPic
//
//  Created by Jerry on 16/4/17.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import "InternetTool.h"
#import "Reachability.h"

@implementation InternetTool

+ (BOOL)isNetConnected
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        
        return NO;
    }
    
    return isExistenceNetwork;
}

@end
