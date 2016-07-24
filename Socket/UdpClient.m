/*
 *  Udp.m
 *  Vann
 *
 *  Created by z gx on 12-1-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UdpClient.h"

//void SetServerSockaddr(int port,struct SockData *sd)
//{
//	int len;
//	int sockfd;
//	struct sockaddr_in ser;
//	
//	bzero(&ser, sizeof(ser));
//	ser.sin_family = AF_INET;
//	ser.sin_addr.s_addr =htonl(INADDR_ANY);
//	ser.sin_port = htons(port);
//	len = sizeof(ser);
//	
//	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
//	if(sockfd == -1)
//	{
//		perror("error!/n");
//		exit(-1);
//	}
//	
//	bind(sockfd, (struct sockaddr *)&ser, sizeof(ser));
//	sd->sockaddrIn=ser;
//	sd->sockFd=sockfd;
//	sd->sockaddrLen=len;
//}
//void SetClientSockaddr(char ip[],int port,struct SockData *cd)
//{
//	struct sockaddr_in cl;
//	int sockfd;
//	int len;
//	sockfd = socket(AF_INET,SOCK_DGRAM,0);
//	if(sockfd == -1)
//	{
//		perror("error!/n");
//		exit(-1);
//	}
//	int broadcast = 1;
//	int num = 0;
//	
//	int ret_val = setsockopt(sockfd,SOL_SOCKET,SO_BROADCAST,&broadcast,sizeof(broadcast));
//	if(ret_val == -1)
//	{
//		perror("Failed in setsockfd /n");
//		exit(-1);
//	}
//	
//	cl.sin_family = AF_INET;
//	cl.sin_port = htons(port);
//	cl.sin_addr.s_addr = inet_addr(ip);
//	
//	len=sizeof(struct sockaddr_in);
//
//	cd->sockaddrIn=cl;
//	cd->sockFd=sockfd;
//	cd->sockaddrLen=len;
//	
//}
//int UDPRecvMsg(struct SockData *sd,char msg[],int strleng,char ipstr[])
//{
//	int len;
////    struct timeval tv_out;
////    tv_out.tv_sec = 10;//等待10秒
////    tv_out.tv_usec = 0;
////    setsockopt(sd->sockFd,SOL_SOCKET,SO_RCVTIMEO,&tv_out, sizeof(tv_out));
//	len=recvfrom(sd->sockFd,msg,strleng,MSG_DONTWAIT,(struct sockaddr *)&(sd->sockaddrIn),&(sd->sockaddrLen));
//    sprintf(ipstr, "%s",(char *)inet_ntoa(sd->sockaddrIn.sin_addr));
//	return len;
//	
//}
//int UDPSendMsg(struct SockData *cd,char msg[],int strleng)
//{
//	int len;
//	len= sendto(cd->sockFd,msg,strleng,0,(struct sockaddr *)&(cd->sockaddrIn),cd->sockaddrLen);
//	return len;
//}
//int closeUdpSocket(struct SockData *cd){
//    close(cd->sockFd);
//    return 0;
//}
//

int SendAndRev(char sendmsg[],int sendlen,char ipstr[],char revmsg[],int revlen,char *revIP){
    int cli_sockfd;
    int len;
    socklen_t addrlen;
    struct sockaddr_in cli_addr;
    /* 建立socket*/
    cli_sockfd=socket(AF_INET,SOCK_DGRAM,0);
    if(cli_sockfd<0)
    {
        printf("I cannot socket success\n");
        return 1;
    }
    int broadcast = 1;
    //int num = 0;
    
    int ret_val = setsockopt(cli_sockfd,SOL_SOCKET,SO_BROADCAST,&broadcast,sizeof(broadcast));
    if(ret_val == -1)
    {
        perror("Failed in setsockfd /n");
        exit(-1);
    }
    /* 填写sockaddr_in*/
    addrlen=sizeof(struct sockaddr_in);
    bzero(&cli_addr,addrlen);
    cli_addr.sin_family=AF_INET;
    cli_addr.sin_addr.s_addr=inet_addr(ipstr);
    //cli_addr.sin_addr.s_addr=htonl(INADDR_ANY);
    cli_addr.sin_port=htons(9559);
    /* 将字符串传送给server端*/
    sendto(cli_sockfd,sendmsg,sendlen,0,(struct sockaddr*)&cli_addr,addrlen);
    /* 接收server端返回的字符串*/
    struct timeval tv;
    //int ret;
    tv.tv_sec = 3;
    tv.tv_usec = 0;
    if(setsockopt(cli_sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv))<0){
        printf("socket option  SO_RCVTIMEO not support\n");
        return -1;
    }
    len=recvfrom(cli_sockfd,revmsg,revlen,0,(struct sockaddr*)&cli_addr,&addrlen);
    //printf("receive from %s\n",inet_ntoa(cli_addr.sin_addr));
    //printf("receive: %s",revmsg);
    sprintf(revIP, "%s",(char *)inet_ntoa(cli_addr.sin_addr));
    close(cli_sockfd);
    return len;
}

