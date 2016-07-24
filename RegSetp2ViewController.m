//
//  RegSetp2ViewController.m
//  InCloud
//
//  Created by vann on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "RegSetp2ViewController.h"
#import "model/AtuInfo.h"
#import "service/CMDService.h"
#import "Constants.h"
#import "MBProgressHUD.h"
@interface RegSetp2ViewController ()<MBProgressHUDDelegate>{
    NSString *atuIdstr;
    NSString *atuNamestr;
    NSString *atupwdstr;
    NSString *atuIpstr;
    NSString *roomNamestr;
    NSString *atuOtherNamestr;
     NSInteger isFirstReq;
    MBProgressHUD *HUD;
}

@end

@implementation RegSetp2ViewController
@synthesize atu,ssid,wifipwd,pairbtn,cbnbtn;

 NSString * const BootProtocol=@"DHCP";
 NSString * const IPAddr=@"192.168.100.1";
 NSString * const Gateway=@"192.168.100.1";
 NSString * const NetworkType=@"Adhoc";
 NSString * const AUTH_MODE=@"WPAPSK";
 NSString * const EncryptType=@"NONE";

- (void)viewDidLoad {
    [super viewDidLoad];
    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:atu];
    atuIdstr=dev.atuId;
    atupwdstr=dev.atuPwd;
    atuIpstr=dev.atuIp;
    isFirstReq=-1;
    [self createClientUdpSocket];
    // Do any additional setup after loading the view.
}


-(void)createClientUdpSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
}


- (IBAction)pairPressed : (id)sender{
    CMDService *cs=[[CMDService alloc] init];
    cs.atuId=atuIdstr;
    cs.atupwd=atupwdstr;
    NSString *setwpastr=[[NSString alloc] initWithFormat:@"%@\r\n ssid=\"%@\"\r\n psk=\"%@\"\r\n key_mgmt=WPA-PSK\r\n priority=96\r\n}",ATU_CMD_WPA,ssid.text,wifipwd.text];
    NSData *data = [cs InCloudCommand:setwpastr];
    [sendUdpSocket sendData:data toHost:atuIpstr port:9559 withTimeout:60 tag:200];
    isFirstReq=1;
    [sendUdpSocket receiveOnce:nil];
}
- (IBAction)calPressed : (id)sender{
     [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
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
    if([s hasPrefix:@"Command_OK"]&&isFirstReq==1){


            CMDService *cs=[[CMDService alloc] init];
            cs.atuId=atuIdstr;
            cs.atupwd=atupwdstr;
            NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@\r\nDEVICE ra0\r\nCHIPSET RT3070\r\nBOOTPROTO %@\r\nIPADDR %@\r\nGATEWAY %@\r\nNETWORK_TYPE %@\r\nSSID %@\r\nAUTH_MODE %@\r\nENCRYPT_TYPE %@\r\nAUTH_KEY %@\r\nWPS_TRIG_KEY POWER\r\n",ATU_CMD_NETWORK,BootProtocol,IPAddr,Gateway,NetworkType,ssid.text,AUTH_MODE,EncryptType,wifipwd.text];
            NSData *data = [cs InCloudCommand:cmdstr];
            [sendUdpSocket sendData:data toHost:atuIpstr port:9559 withTimeout:60 tag:200];
            isFirstReq=2;
            [sendUdpSocket receiveOnce:nil];
            s=@"";
        
    }if([s hasPrefix:@"Command_OK"]&&isFirstReq==2){
        [sendUdpSocket close];
         dispatch_async(dispatch_get_main_queue(),^{
           [self showWithCustomView:@"配置成功,请切换到您的WiFi环境"];
         });
        isFirstReq=-1;
        s=@"";
        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    }
}

- (void)showWithCustomView:(NSString *)msgstr{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = self;
    HUD.labelText = msgstr;
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
