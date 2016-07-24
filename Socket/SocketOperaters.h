//
//  SocketOperater.h
//  Vann
//
//  Created by z gx on 12-8-8.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "UdpClient.h"
#define SRV_CONNECTED 0  
#define SRV_CONNECT_SUC 1  
#define SRV_CONNECT_FAIL 2   


@interface SocketOperaters : NSObject {
	
}

-(NSString *)ReadSend:(NSString *)atuIp AtuPort:(NSInteger)atuport SendData:(NSData *)data;

@end
