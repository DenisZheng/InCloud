//
//  SocketOperater.m
//  Vann
//
//  Created by z gx on 12-8-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SocketOperaters.h"

@implementation SocketOperaters

//SData cd;

////Socket初始化
//-(void)ConectUpd
//{
//	//SetClientSockaddr([[GlobalClass sharedGlobalClass].wsip cString], Control_PORT, &cd);
//	SetClientSockaddr([[GlobalClass sharedGlobalClass].wsip cString], Control_PORT, &cd);
//}
//-(void)ConectSocket
//{
//	//int i=init_Client([[GlobalClass sharedGlobalClass].wsip UTF8String], [[GlobalClass sharedGlobalClass].wsport intValue]);
//    //SetClientSockaddr([[GlobalClass sharedGlobalClass].wsip cString], [[GlobalClass sharedGlobalClass].wsport intValue], &scd);
//}
//建立基于TCP的Socket连接

//-(void)Send:(NSString *)data{
//    [self ConectUpd];
//    int count=8;
//    unsigned char msg[count]; 
//	UDPSendMsg(&cd,[[StringOperater ToNsData:data] bytes],count); 
//	//usleep(1000*20);
//	//bzero(&msg,sizeof(msg));
//	//UDPRecvMsg(&cd,msg,count);
//     [self closeUdp];
//}

-(NSString *)ReadSend:(NSString *)atuIp AtuPort:(NSInteger)atuport SendData:(NSData *)data
{
    
    unsigned char msg[1024];
    unsigned char iparray[1024];

	NSString *tmpStr=nil;
    NSString *ipstr=nil;
    
   // int sendi=UDPSendMsg(&cd,[data bytes],[data length]);
    // NSLog(@"send:i=%d",sendi);
    bzero(&msg,sizeof(msg));
    bzero(&iparray, sizeof(iparray));
    //usleep(5000*100);
    //int i=UDPRecvMsg(&cd,msg,1024,iparray);
    int i=SendAndRev([data bytes],[data length],[atuIp cStringUsingEncoding:NSUTF8StringEncoding],msg,sizeof(msg),iparray);
    if (i<0) {
         NSLog(@"Read:%@,i=%d,ip:%@",tmpStr,i,ipstr);
        
         return @"";
    }else{
        tmpStr = [NSString stringWithUTF8String:&msg];
        ipstr=[NSString stringWithUTF8String:&iparray];
        NSLog(@"Read:%@,i=%d,ip:%@",tmpStr,i,ipstr);
        return  ipstr;
    }
}


@end
