//
//  RegStep1ViewController.m
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "RegStep1ViewController.h"
#import "AtuInfo.h"
#import "Constants.h"
#import "CMDService.h"
#import "ConfigService.h"
#import "MBProgressHUD.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface RegStep1ViewController ()<MBProgressHUDDelegate>{
    UIAlertView *alert;
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

@implementation RegStep1ViewController
@synthesize atuId,atuName,atuOthername,roomName,pairNextBtn,pairCalBtn;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    isFirstReq=-1;
     alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"1.初次配对,请手动链接AIR100_AP热点\r\n2.网络环境没有改变则无须更换热点\r\n3.链接热点后返回,短按一次配对键\r\n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];

}


- (IBAction)nextPressed : (id)sender{
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    CMDService *cs=[[CMDService alloc] init];
    cs.atuId=atuIdstr;
    cs.atupwd=atupwdstr;
    NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@%@,%@,%@,",ATU_CMD_NMROOM,atuNamestr,atuOthername.text,roomName.text];
    NSData *data = [cs InCloudCommand:cmdstr];
    [sendUdpSocket sendData:data toHost:atuIpstr port:9559 withTimeout:60 tag:200];
    isFirstReq=3;
    [sendUdpSocket receiveOnce:nil];
}
- (IBAction)calPressed : (id)sender{
    AtuInfo *atu=[AtuInfo new];
    atu.atuId=atuIdstr;
    atu.atuCode=atuNamestr;
    atu.atuName=atuOthername.text;
    atu.atuRoom=roomName.text;
    atu.atuPwd=atupwdstr;
    atu.atuIp=atuIpstr;
    int isEx=0;
    ConfigService *cs=[ConfigService new];
    NSMutableArray *atus=[cs LoadAtusData];
    if ([atus count]>0) {
        for (int  i=0; i<[atus count]; i++) {
            NSData *data=[atus objectAtIndex:i];
            AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([dev.atuId isEqualToString:atu.atuId]) {
                isEx=1;
                dev.atuCode=atu.atuCode;
                dev.atuName=atu.atuName;
                dev.atuRoom=atu.atuRoom;
                dev.atuPwd=atu.atuPwd;
                atu.atuIp=dev.atuIp;
                break;
            }
        }
        if (isEx==0) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
            [atus addObject:data];
            [cs SaveAtusData:atus];
        }
    }else{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
        [atus addObject:data];
        [cs SaveAtusData:atus];
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    RegSetp2ViewController *vc=[mainStoryboard instantiateViewControllerWithIdentifier: @"RegStep2ViewController"];
    vc.atu=[NSKeyedArchiver archivedDataWithRootObject:atu];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

-(void)pairatuSocket{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"正在搜索设备.....";
    [HUD show:YES];
    //创建一个后台队列 等待接收数据
    dispatch_queue_t dQueue = dispatch_queue_create("My socket queue", NULL); //第一个参数是该队列的名字
    //1.实例化一个udp socket套接字对象
    // udpServerSocket需要用来接收数据
    udpServerSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [udpServerSocket setIPv4Enabled:YES];
    [udpServerSocket setIPv6Enabled:NO];
    //2.服务器端来监听端口12345(等待端口12345的数据)
    [udpServerSocket bindToPort:9558 error:nil];
    
    //3.接收一次消息(启动一个等待接收,且只接收一次)
    [udpServerSocket receiveOnce:nil];
}

-(void)createClientUdpSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    
    //1.创建一个 udp socket用来和服务器端进行通讯
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [sendUdpSocket setIPv4Enabled:YES];
    [sendUdpSocket setIPv6Enabled:NO];
    //2.banding一个端口(可选),如果不绑定端口, 那么就会随机产生一个随机的电脑唯一的端口
    //端口数字范围(1024,2^16-1)
   // [sendUdpSocket bindToPort:9559 error:nil];
    
    //3.等待接收对方的消息
    //[sendUdpSocket receiveOnce:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [alert dismissWithClickedButtonIndex:buttonIndex animated:NO];
    }else{
        
        if ([self IsSSIDEx]) {
            
        }else{
            if (iOS8) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[[UIAlertView alloc]initWithTitle:@"提示" message:@"请进入WIFI设置手动选择SSID" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
            }
        }
        [self pairatuSocket];
    }
    
}

- (NSString *) getDeviceSSID
{
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];
    return ssid;
    
}

-(BOOL)IsSSIDEx{
    NSString   *currssid=[self getDeviceSSID];
    int result1 = [currssid compare:@"AIR100_AP" options:NSCaseInsensitiveSearch | NSNumericSearch];
    if(result1==0){
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
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

    atuIpstr=ip;
    
//    NSString *s1 = [[NSString alloc] initWithData:data encoding:NSGBK];
    
    NSLog(@"[%@:%u]%@",ip, port,s);
    if ([s hasPrefix:@"AtuServer,"]) {
        atuIpstr=ip;
        NSArray *array = [s componentsSeparatedByString:@","];
        atuIdstr=[array objectAtIndex:1];
        atuNamestr=[array objectAtIndex:3];
        atupwdstr=[array objectAtIndex:4];
        dispatch_async(dispatch_get_main_queue(),^{
            [HUD hide:YES];
            [atuId setText:atuIdstr];
            [atuName setText:atuNamestr];
        
        });
        CMDService *cs=[[CMDService alloc] init];
        cs.atuId=atuIdstr;
        cs.atupwd=atupwdstr;
        //NSString *cmd=[[NSString alloc] initWithFormat:@"%@",
        NSData *data = [cs InCloudCommand:ATU_CMD_GETROOM];
        [udpServerSocket  close];
        [self createClientUdpSocket];
        //dispatch_queue_t dQueue = dispatch_queue_create("com.getroom.getairname", DISPATCH_QUEUE_SERIAL);
        [sendUdpSocket sendData:data toHost:ip port:9559 withTimeout:60 tag:200];
        isFirstReq=1;
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//           [sendUdpSocket sendData:data toHost:ip port:9559 withTimeout:60 tag:200];
//        });
        [sendUdpSocket receiveOnce:nil];
    }if([s hasPrefix:@"Command="]&&isFirstReq==1){
        if([s isEqualToString:@"Command="]){
            dispatch_async(dispatch_get_main_queue(),^{
                
                [atuOthername setText:@""];
                [roomName setText:@""];
                
            });
        }else{
            NSArray *array = [s componentsSeparatedByString:@"="];
            NSString *str1=[array objectAtIndex:1];
            NSArray *rmstr=[str1 componentsSeparatedByString:@","];
            roomNamestr=[rmstr objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(),^{
                [roomName setText:roomNamestr];
            });
//            String scenestr="一键开启:"+roomName.getText().toString().trim()
//            + ","+atuotherName.getText().toString()
//            .trim() + ","+"1A,01,62,37,;";
            CMDService *cs=[[CMDService alloc] init];
            cs.atuId=atuIdstr;
            cs.atupwd=atupwdstr;
            NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@%@,",ATU_CMD_RDROOM,roomNamestr];
            NSData *data = [cs InCloudCommand:cmdstr];
            [sendUdpSocket sendData:data toHost:ip port:9559 withTimeout:60 tag:200];
            isFirstReq=2;
            [sendUdpSocket receiveOnce:nil];
            s=@"";
        }
    }if([s hasPrefix:@"Command="]&&isFirstReq==2){
        if(![s isEqualToString:@"Command="]){
            NSArray *array = [s componentsSeparatedByString:@"="];
            NSString *str1=[array objectAtIndex:1];
            NSArray *devstr=[str1 componentsSeparatedByString:@","];
            atuOtherNamestr=[devstr objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(),^{
                [atuOthername setText:atuOtherNamestr];
            });
            AtuInfo *atu=[AtuInfo new];
            atu.atuId=atuIdstr;
            atu.atuCode=atuNamestr;
            atu.atuName=atuOtherNamestr;
            atu.atuRoom=roomNamestr;
            atu.atuPwd=atupwdstr;
            atu.atuIp=atuIpstr;
            int isEx=0;
            ConfigService *cs=[ConfigService new];
            NSMutableArray *atus=[cs LoadAtusData];
            if ([atus count]>0) {
                for (int  i=0; i<[atus count]; i++) {
                    NSData *data=[atus objectAtIndex:i];
                    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
                    if ([dev.atuId isEqualToString:atu.atuId]) {
                        isEx=1;
                        dev.atuCode=atu.atuCode;
                        dev.atuName=atu.atuName;
                        dev.atuRoom=atu.atuRoom;
                        dev.atuPwd=atu.atuPwd;
                        atu.atuIp=dev.atuIp;
                        NSData *devdata=[NSKeyedArchiver archivedDataWithRootObject:dev];
                        [atus replaceObjectAtIndex:i withObject:devdata];
                        break;
                    }
                }
                if (isEx==0) {
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
                    [atus addObject:data];
                    [cs SaveAtusData:atus];
                }
            }else{
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
                [atus addObject:data];
                [cs SaveAtusData:atus];
            }
            [cs SaveAtusData:atus];
            isFirstReq=-1;
             s=@"";
            [sendUdpSocket close];
        }
    }if([s hasPrefix:@"Command=1"]&&isFirstReq==3){
        AtuInfo *atu=[AtuInfo new];
        atu.atuId=atuIdstr;
        atu.atuCode=atuNamestr;
        atu.atuName=atuOthername.text;
        atu.atuRoom=roomName.text;
        atu.atuPwd=atupwdstr;
        atu.atuIp=atuIpstr;
        int isEx=0;
        ConfigService *cs=[ConfigService new];
        NSMutableArray *atus=[cs LoadAtusData];
        if ([atus count]>0) {
            for (int  i=0; i<[atus count]; i++) {
                NSData *data=[atus objectAtIndex:i];
                AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
                if ([dev.atuId isEqualToString:atu.atuId]) {
                    isEx=1;
                    dev.atuCode=atu.atuCode;
                    dev.atuName=atu.atuName;
                    dev.atuRoom=atu.atuRoom;
                    dev.atuPwd=atu.atuPwd;
                    dev.atuIp=atu.atuIp;
                    NSData *devdata=[NSKeyedArchiver archivedDataWithRootObject:dev];
                    [atus replaceObjectAtIndex:i withObject:devdata];
                    break;
                }
            }
            if (isEx==0) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
                [atus addObject:data];
                [cs SaveAtusData:atus];
            }
        }else{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
            [atus addObject:data];
            [cs SaveAtusData:atus];
        }
        [cs SaveAtusData:atus];
        CMDService *cms=[[CMDService alloc] init];
        cms.atuId=atuIdstr;
        cms.atupwd=atupwdstr;
        NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@一键开启:%@,%@,1A,01,62,37,;",ATU_CMD_WRSCENE,roomName.text,atuOthername.text];
        NSData *data = [cms InCloudCommand:cmdstr];
        [sendUdpSocket sendData:data toHost:ip port:9559 withTimeout:60 tag:200];
        //isFirstReq=4;
        [sendUdpSocket receiveOnce:nil];
        isFirstReq=-1;
        s=@"";
        [sendUdpSocket close];
        dispatch_async(dispatch_get_main_queue(),^{
//            RegSetp2ViewController *rs=[[RegSetp2ViewController  alloc]init];
//            rs.atu=[NSKeyedArchiver archivedDataWithRootObject:atu];
//            [self.navigationController pushViewController:rs animated:YES];
            //[self performSegueWithIdentifier:@"step2Segue" sender:nil];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            RegSetp2ViewController *vc=[mainStoryboard instantiateViewControllerWithIdentifier: @"RegStep2ViewController"];
            vc.atu=[NSKeyedArchiver archivedDataWithRootObject:atu];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                     withSlideOutAnimation:NO
                                                                             andCompletion:nil];

        });
        //然后跳转
    }
    
    
}

-(void)setatuText:(NSString *)tttt{
    [atuId setText:tttt];
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
