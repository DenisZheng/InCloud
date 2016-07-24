/*
 *  Udp.h
 *  Vann
 *
 *  Created by z gx on 12-1-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UDP_H
#define _UDP_H
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include<errno.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include <netinet/in.h>
#import <arpa/inet.h>

typedef struct SockData
{
	struct sockaddr_in sockaddrIn;
	int sockFd;
	int sockaddrLen;
}SData;

//void SetServerSockaddr(int port,struct SockData *sd);//初始化服务器端
//void SetClientSockaddr(char ip[],int port,struct SockData *cd);//初始化客户端
//int UDPRecvMsg(struct SockData *sd,char msg[],int strleng,char *ipstr);//接受消息 返回接受字节长度
//int UDPSendMsg(struct SockData *cd,char msg[],int strleng);//发送消息 返回发送字节长度
//int closeUdpSocket(struct SockData *cd);

int SendAndRev(char sendmsg[],int sendlen,char ipstr[],char revmsg[],int revlen,char *revIP);
#endif