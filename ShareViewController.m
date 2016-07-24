//
//  ShareViewController.m
//  InCloud
//
//  Created by Denis on 15/8/1.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "ShareViewController.h"
#import "MyIPHelper.h"
#import "MBProgressHUD.h"
#import "service/ConfigService.h"

@interface ShareViewController()<MBProgressHUDDelegate> {
    NSInteger isSrv;
    MBProgressHUD *HUD;
    NSMutableString *jsonString;
    ConfigService *cs;
}

@end

@implementation ShareViewController
@synthesize curip,sharetitle,sendip,shareclient,sharesrv;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cs=[[ConfigService alloc] init];
    sharetitle.text=[[NSString alloc] initWithFormat:@"接收方按‘建立连接’，发送方按‘共享’"];
    curip.text=[[NSString alloc] initWithFormat:@"当前WiFi-IP：%@",[MyIPHelper deviceIPAdress]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createSrv{
    jsonString=[[NSMutableString alloc] init];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"接收数据中....";
    [HUD show:YES];
    //创建一个后台队列 等待接收数据
    dispatch_queue_t dQueue = dispatch_queue_create("rev socket queue", NULL); //第一个参数是该队列的名字
    //1.实例化一个udp socket套接字对象
    // udpServerSocket需要用来接收数据
    udpServerSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [udpServerSocket setIPv4Enabled:YES];
    [udpServerSocket setIPv6Enabled:NO];
    //2.服务器端来监听端口12345(等待端口12345的数据)
    [udpServerSocket bindToPort:18888 error:nil];
    isSrv=1;
    //3.接收一次消息(启动一个等待接收,且只接收一次)
    [udpServerSocket receiveOnce:nil];
}


-(void)createClientUdpSocket{
    if ((sendip.text.length>0)&&[self validateIp:sendip.text]) {

    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"共享数据中....";
    [HUD show:YES];
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [sendUdpSocket setIPv4Enabled:YES];
    [sendUdpSocket setIPv6Enabled:NO];
    [sendUdpSocket bindToPort:19999 error:nil];
    NSString *sendjson=[cs AtusToJsonList];
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
     NSData *cmddata = [sendjson dataUsingEncoding:strEncode];
    [sendUdpSocket sendData:cmddata toHost:sendip.text port:18888 withTimeout:60 tag:200];
     isSrv=2;
    [sendUdpSocket receiveOnce:nil];
        
    }else{
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"文本框IP不能为空或IP格式不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

- (BOOL)validateIp:(NSString *)ipstr {
    NSString *ipRegex = @"^(d{1,2}|1dd|2[0-4]d|25[0-5]).(d{1,2}|1dd|2[0-4]d|25[0-5]).(d{1,2}|1dd|2[0-4]d|25[0-5]).(d{1,2}|1dd|2[0-4]d|25[0-5])$";
    
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    return [ipTest evaluateWithObject:ipstr];
}

- (IBAction)sendPressed : (id)sender{
    [self createClientUdpSocket];
}
- (IBAction)revPressed : (id)sender{
    [self createSrv];
}

#pragma mark -GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContex
{
    
    //取得发送发的ip和端口
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    //data就是接收的数据
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *s = [[NSString alloc] initWithData: data encoding:strEncode];

    
    NSLog(@"[%@:%u]%@",ip, port,s);
    if (isSrv==1) {
        if ([s isEqualToString:@"end"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [udpServerSocket  close];
                [HUD hide:YES];
            });
            NSLog(@"json str:%@",[jsonString copy]);
            isSrv=-1;
            NSMutableArray *atus=[cs JsonListToAtus:jsonString];
            [cs SaveAtusData:atus];
        }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 [jsonString appendString:s];
             });
        NSData *cmddata = [@"ok" dataUsingEncoding:NSUTF8StringEncoding];
        [udpServerSocket sendData:cmddata toHost:ip port:port withTimeout:60 tag:200];
        [udpServerSocket receiveOnce:nil];
        }
    }else if(isSrv==2){
        if ([s isEqualToString:@"ok"]) {
            NSData *cmddata = [@"end" dataUsingEncoding:NSUTF8StringEncoding];
            [sendUdpSocket sendData:cmddata toHost:ip port:port withTimeout:60 tag:200];
            [sendUdpSocket receiveOnce:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [sendUdpSocket  close];
                [HUD hide:YES];
            });
            isSrv=-1;
        }
    }
    
   
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{

    NSLog(@"tag:%ld,%@",tag, error);
}

-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"Socket closed, error: %@", error);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Socket send, tag: %ld", tag);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    NSLog(@"Failed to connect to host, error: %@", error);
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
