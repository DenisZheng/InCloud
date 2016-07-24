//
//  MyIPHelper.m
//  InCloud
//
//  Created by Denis on 15/7/11.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "MyIPHelper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
@implementation MyIPHelper

+ (NSString *)deviceIPAdress{
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);  
    
    NSLog(@"手机的IP是：%@", address);
    return address;
}
+(NSString *)boardcastIPAdress{
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    if ([address isEqualToString:@"an error occurred when obtaining ip address"]) {
        return @"192.168.100.255";
    }
    NSArray *array = [address componentsSeparatedByString:@"."];
    NSString *boardcastadr=[[NSString alloc]initWithFormat:@"%@.%@.%@.255",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]];
    NSLog(@"手机的广播IP是：%@", boardcastadr);
    return boardcastadr;
}

@end
