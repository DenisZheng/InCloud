//
//  ControlViewController.m
//  InCloud
//
//  Created by Denis on 15/7/12.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "ControlViewController.h"
#import "ConfigService.h"
#import "Constants.h"
#import "CMDService.h"
#import "DaiKinStatus.h"
#import "MBProgressHUD.h"
@interface ControlViewController ()<MBProgressHUDDelegate>{
    DaiKinStatus *dkStatus;
    DaiKinStatus *setStatus;
    CMDService *DaiKin;
    ConfigService *cs;
    bool boolRunning;
    bool bFirstRun;
    bool bNeeRead;
    bool s_bNeedLock;
    bool s_bNeedWrite;
    bool bSlowCtr;
    NSString *controlIp;
    NSInteger controlPort;
    NSInteger fixvalue;
    NSInteger powervalue;
    NSInteger tmpvalue;
    NSInteger iTimer10 ;
    NSInteger iTimer5 ;
    NSInteger iTimer2;
    NSInteger iReadWrite;
     MBProgressHUD *HUD;
}

@end


@implementation ControlViewController
@synthesize slider,centerView,coldbtn,heatbtn,dehubtn,fanbtn,fixbtn,slowbtn,centerbtn,strongbtn,upbtn,downbtn,onoffview,modeview,fanview,fixview,settmpview,curtmpview,powerbtn,atu,airtimer;
- (void)viewDidLoad {
    [super viewDidLoad];
//    unsigned long red = strtoul([@"1A" UTF8String],0,16);
//    NSLog(@"转换完的数字为：%lu",red);
    [self InitValue];
    slider.value = 0;
    slider.maximumValue = 16;
    slider.minimumValue = 0;
    slider.transform = CGAffineTransformMakeRotation(-1.57079633);
    [slider setMaximumTrackImage:[UIImage imageNamed:@"progress_bar_bottom.png"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"progress_bar.png"] forState:UIControlStateNormal];

        [slider setThumbImage:[UIImage imageNamed:@"thum_c.png"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage imageNamed:@"thum_c.png"] forState:UIControlStateHighlighted];

    [slider addTarget:self action:@selector(tmpSwip:) forControlEvents:UIControlEventValueChanged];
    [powerbtn setTitleEdgeInsets:UIEdgeInsetsMake(30, 0, 0, 0)];
    //delay 1s start nstimer;
   
       airtimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(airtask) userInfo:nil repeats:YES];
    

}

-(void)createClientUdpSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [udpSocket setIPv4Enabled:YES];
    [udpSocket setIPv6Enabled:NO];
}


-(void)InitValue{
    setStatus=[DaiKinStatus new];
    dkStatus=[DaiKinStatus new];
    DaiKin=[[CMDService alloc] init];
    cs=[[ConfigService alloc] init];
    boolRunning=true;
    bFirstRun=true;
    bNeeRead=false;
    s_bNeedLock=false;
    s_bNeedWrite=false;
    bSlowCtr=false;
    if (atu.isRemote==LAN_CTR_MODE) {
        controlIp=atu.atuIp;
        controlPort=9559;
    }else if(atu.isRemote==REMO_CTR_MODE){
        controlIp=atu.atuRemoIp;
        controlPort=atu.atuRemoPort;
    }else if (atu.isRemote==SLOW_CTR_MODE){
        bSlowCtr=true;
    }
    setStatus.SetTemp=TEMP_MIN;
    dkStatus.SetTemp=TEMP_MIN;
     iTimer10=0;
     iTimer5=0 ;
     iTimer2=0;
    if (!bSlowCtr) {
        [self createClientUdpSocket];
    }
    
}

-(void)airtask{
    if (boolRunning==true) {
        if (bFirstRun) {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.dimBackground = YES;
            HUD.delegate = self;
            HUD.labelText = @"努力加载中.....";
            [HUD show:YES];
        }
        iTimer2++;
        iTimer5++;
        iTimer10++;
        if (bNeeRead) {
            bNeeRead=false;
            iTimer10=0;
            if (bSlowCtr) {
                [self execute:ATU_CTR_SLOW DataType:CMD_GET_DATA CmdStr:@""];
            }else{
                [self execute:ATU_CMD_INCLOUD DataType:CMD_GET_DATA CmdStr:@""];
            }
        }
        if (setStatus.Timer > 0) {
            setStatus.Timer--;
        }
        if (iTimer2 >= 2) { // 2 second
            iTimer2 = 0;
            if (([self CheckControl] == YES) && (s_bNeedWrite == true)) {
                s_bNeedWrite = false;
                iTimer5 = 0;
                iTimer10 = 0;
                
                if (bSlowCtr) {
                     [self execute:ATU_CTR_SLOW DataType:CMD_SET_DATA CmdStr:[DaiKin BuildDataString:setStatus]];
                } else {
                   [self execute:ATU_CMD_INCLOUD DataType:CMD_SET_DATA CmdStr:[DaiKin BuildDataString:setStatus]];
                }
            }
        }
        if (iTimer5 >= 11) { // 10 second
            iTimer5 = 0;
            if (!bSlowCtr) {
                if (powerbtn != nil) {
                    [powerbtn setTitle:[NSString stringWithFormat: @"%d",dkStatus.RoomTemp] forState:UIControlStateNormal];
                    //powerbtn.titleLabel.text=[NSString stringWithFormat: @"%d",dkStatus.RoomTemp];
                }
                if (setStatus.Timer > 0) { // I am wait echo,
                    // refresh
                    // data ever 5 second
                    iTimer10 = 0;
                     [self execute:ATU_CMD_INCLOUD DataType:CMD_GET_DATA CmdStr:@""];
                }
            }
        }
        if (iTimer10 >= 40) { // 40s
            if (!bSlowCtr) {
                iTimer10 = 0; // Refresh data ever 30 second
                bFirstRun = true; // refresh status
                 [self execute:ATU_CMD_INCLOUD DataType:CMD_GET_DATA CmdStr:@""];
            }
        }
        if (iTimer10 >= 60) {
            iTimer10 = 0;
            bFirstRun = true;
             [self execute:ATU_CTR_SLOW DataType:CMD_GET_DATA CmdStr:@""];
        }
    }
    else{
        iTimer5 = 0;
    }
}

-(void)execute:(NSString *)cmdtype DataType:(NSString *)datatype CmdStr:(NSString *)cmd{
    iReadWrite=0;
    if (![cmdtype isEqualToString:ATU_CTR_SLOW]) {
        DaiKin.atuId=atu.atuId;
        DaiKin.atupwd=atu.atuPwd;
        if ([datatype isEqualToString:CMD_GET_DATA]) {
            iReadWrite = 0;
            NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@%@,",CMD_GET_DATA,atu.atuRoom];
            NSData *data = [DaiKin InCloudCommand:cmdstr];
            [udpSocket sendData:data toHost:controlIp port:controlPort withTimeout:5 tag:200];
            [udpSocket receiveOnce:nil];
        }else if([datatype isEqualToString:CMD_SET_DATA]){
            iReadWrite = 1;
            NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@%@,%@,%@",CMD_SET_DATA,atu.atuRoom,atu.atuName,cmd];
            NSData *data = [DaiKin InCloudCommand:cmdstr];
            [udpSocket sendData:data toHost:controlIp port:controlPort withTimeout:5 tag:200];
            [udpSocket receiveOnce:nil];
        }
    }else{
        NSString *usrName=[cs GetLoginName];
        NSString *usrpwd=[cs GetPwd];
        if ([datatype isEqualToString:CMD_GET_DATA]) {
            iReadWrite = 0;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSString *slowrev=[cs RemControl:usrName Pwd:usrpwd Serial:atu.atuId AirPass:atu.atuPwd CMD:@""];
                if ([slowrev length]>0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self myAirStatCallBack:ATU_CTR_SLOW StrEcho:slowrev];
                    });
                    if (bFirstRun) {
                        //dialog.dismiss();
                        bFirstRun = false;
                         [HUD hide:YES];
                        dispatch_async(dispatch_get_main_queue(),^{
                            [HUD hide:YES];
                            [self SetRunMode];
                        });
                    }
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self ShowStatus];
                    });
                    if ([self CheckSameStatus]) {
                        setStatus.Timer = 0;
                    }
                    
                }
            });
            
        }else if([datatype isEqualToString:CMD_SET_DATA]){
            iReadWrite = 1;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@_%@",atu.atuCode,cmd];
                NSString *slowrev=[cs RemControl:usrName Pwd:usrpwd Serial:atu.atuId AirPass:atu.atuPwd CMD:cmdstr];
            });
        }
    }
     if (bFirstRun) {
         [HUD hide:YES];
     }
}


-(void)myAirStatCallBack:(NSString *)cmdtype StrEcho:(NSString *)str{
    if (![cmdtype isEqualToString:ATU_CTR_SLOW]) {
        if (iReadWrite == 0) { // Read data
            NSArray *strValue = [str componentsSeparatedByString:@","];
            if ([strValue count] >= 17) {
                int i = 1;
                //airName = strValue[0];
                dkStatus.SetTemp = strtoul([[strValue objectAtIndex:i+0] UTF8String],0,16);
                dkStatus.Power = strtoul([[strValue objectAtIndex:i+6] UTF8String],0,16);
                dkStatus.RunMode = strtoul([[strValue objectAtIndex:i+7] UTF8String],0,16);
                dkStatus.FanSpeed = strtoul([[strValue objectAtIndex:i+8] UTF8String],0,16)>> 4;
                dkStatus.FanScan = strtoul([[strValue objectAtIndex:i+8] UTF8String],0,16) & 0x0F;
                dkStatus.RoomTemp = strtoul([[strValue objectAtIndex:i+1] UTF8String],0,16);
//                if (strValue[i + 16].contains("1")) {
//                    dkStatus.Locked = true;
//                } else {
//                    dkStatus.Locked = false;
//                }
//                dkStatus.Alarm = "";
//                try {
//                    char[] c = new char[2];
//                    c[0] = (char) HexStringToInt(strValue[i + 14]);
//                    c[1] = (char) HexStringToInt(strValue[i + 15]);
//                    if ((c[0] != 0) && (c[1] != 0)) {
//                        dkStatus.Alarm = new String(c);
//                    }
//                } catch (Exception ex) {
//                    
//                }
//                setStatus.Alarm = dkStatus.Alarm;
//                setStatus.Locked = dkStatus.Locked;
                setStatus.RoomTemp = dkStatus.RoomTemp;
                if (bFirstRun) {
                    setStatus.SetTemp = dkStatus.SetTemp;
                    setStatus.Power = dkStatus.Power;
                    setStatus.RunMode = dkStatus.RunMode;
                    setStatus.FanScan = dkStatus.FanScan;
                    setStatus.FanSpeed = dkStatus.FanSpeed;
                }
            }
        }
    }else{
        if (iReadWrite == 0) { // Read data
             NSArray *strValue = [str componentsSeparatedByString:@";"];
            NSArray *Status = [[strValue objectAtIndex:1] componentsSeparatedByString:@"_"];
            NSArray *staParm = [[Status objectAtIndex:1] componentsSeparatedByString:@","];;
            if ([staParm count] >= 16) {
                int i=0;
                dkStatus.SetTemp = strtoul([[staParm objectAtIndex:i+0] UTF8String],0,16);
                dkStatus.Power = strtoul([[staParm objectAtIndex:i+6] UTF8String],0,16);
                dkStatus.RunMode = strtoul([[staParm objectAtIndex:i+7] UTF8String],0,16);
                dkStatus.FanSpeed = strtoul([[staParm objectAtIndex:i+8] UTF8String],0,16)>> 4;
                dkStatus.FanScan = strtoul([[staParm objectAtIndex:i+8] UTF8String],0,16) & 0x0F;
                dkStatus.RoomTemp = strtoul([[staParm objectAtIndex:i+1] UTF8String],0,16);
                setStatus.RoomTemp = dkStatus.RoomTemp;
                if (bFirstRun) {
                    setStatus.SetTemp = dkStatus.SetTemp;
                    setStatus.Power = dkStatus.Power;
                    setStatus.RunMode = dkStatus.RunMode;
                    setStatus.FanScan = dkStatus.FanScan;
                    setStatus.FanSpeed = dkStatus.FanSpeed;
                }
            }
        }
    }
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
    if ([s hasPrefix:@"Command="]) {
        if (iReadWrite == 0) { // read
            [self myAirStatCallBack:ATU_CMD_INCLOUD StrEcho:s];
            if (bFirstRun) {
                //dialog.dismiss();
                bFirstRun = false;
                dispatch_async(dispatch_get_main_queue(),^{
                  [HUD hide:YES];
                  [self SetRunMode];
                });
            }
            dispatch_async(dispatch_get_main_queue(),^{
               [self ShowStatus];
            });
            if ([self CheckSameStatus]) {
                setStatus.Timer = 0;
            }
        } else if (iReadWrite == 1) { // Control success
            
            setStatus.Timer = 60;
        } else { // other command
            setStatus.Timer = 60;
        }
    }
}


-(void) SetRunMode {
    if (dkStatus.Power == 1) {
        [onoffview setImage:[UIImage imageNamed:@"sta_on.png"]];
        [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg_press.png"] forState:UIControlStateNormal];
    } else {
        [onoffview setImage:[UIImage imageNamed:@"sta_off.png"]];
        [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg.png"] forState:UIControlStateNormal];
    }
    if (settmpview != nil) {
        slider.value=dkStatus.SetTemp-16;
        NSString *tmpstr=[[NSString alloc] initWithFormat:@"set%d.png",dkStatus.SetTemp];
        [settmpview setImage:[UIImage imageNamed:tmpstr]];

    }
    
    if (powerbtn != nil){
        [powerbtn setTitle:[NSString stringWithFormat: @"%d",dkStatus.RoomTemp] forState:UIControlStateNormal];
       //powerbtn.titleLabel.text=[NSString stringWithFormat: @"%d",dkStatus.RoomTemp];
    }
    
    if (dkStatus.RunMode == RUN_MODE_COLD) {
        [modeview setImage:[UIImage imageNamed:@"stacold.png"]];
    }
    if (dkStatus.RunMode == RUN_MODE_HEAT) {
        [modeview setImage:[UIImage imageNamed:@"staheat.png"]];
    }
    if (dkStatus.RunMode == RUN_MODE_FAN) {
        [modeview setImage:[UIImage imageNamed:@"stafan.png"]];
    }
    if (dkStatus.RunMode == RUN_MODE_DRY) {
        [modeview setImage:[UIImage imageNamed:@"stadehu.png"]];
    }
    if (dkStatus.RunMode == RUN_MODE_AUTO) {
        [modeview setImage:[UIImage imageNamed:@"staauto.png"]];
    }
    if (dkStatus.FanSpeed == FAN_SPEED_MIN) {
        [fanview setImage:[UIImage imageNamed:@"staslow.png"]];
    }
    if (dkStatus.FanSpeed > FAN_SPEED_MIN
        & dkStatus.FanSpeed < FAN_SPEED_MAX) {
       [fanview setImage:[UIImage imageNamed:@"stacenter.png"]];
    }
    if (dkStatus.FanSpeed == FAN_SPEED_MAX) {
        [fanview setImage:[UIImage imageNamed:@"stastrong.png"]];
    }
    if (dkStatus.FanScan == FAN_FIX) {
       [fixview setImage:[UIImage imageNamed:@"stafix.png"]];
    }
    if (dkStatus.FanScan == FAN_SCAN) {
        [fixview setImage:[UIImage imageNamed:@"stascan.png"]];
    }
    s_bNeedWrite = true;
}

-(void)ShowStatus{
    if (dkStatus == nil) {
        return;
    }
    
    
    if (setStatus.Power == 1) {
        [onoffview setImage:[UIImage imageNamed:@"sta_on.png"]];
        [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg_press.png"] forState:UIControlStateNormal];
    } else {
        [onoffview setImage:[UIImage imageNamed:@"sta_off.png"]];
        [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg.png"] forState:UIControlStateNormal];
    }
    if (settmpview != nil) {
        slider.value=setStatus.SetTemp-16;
        NSString *tmpstr=[[NSString alloc] initWithFormat:@"set%d.png",setStatus.SetTemp];
        [settmpview setImage:[UIImage imageNamed:tmpstr]];
        
    }

    if (powerbtn != nil){
        [powerbtn setTitle:[NSString stringWithFormat: @"%d",setStatus.RoomTemp] forState:UIControlStateNormal];
        //powerbtn.titleLabel.text=[NSString stringWithFormat: @"%d",setStatus.RoomTemp];
    }
    if (setStatus.RunMode == RUN_MODE_COLD) {
        [modeview setImage:[UIImage imageNamed:@"stacold.png"]];
    }
    if (setStatus.RunMode == RUN_MODE_HEAT) {
        [modeview setImage:[UIImage imageNamed:@"staheat.png"]];
    }
    if (setStatus.RunMode == RUN_MODE_FAN) {
        [modeview setImage:[UIImage imageNamed:@"stafan.png"]];
    }
    if (setStatus.RunMode == RUN_MODE_DRY) {
        [modeview setImage:[UIImage imageNamed:@"stadehu.png"]];
    }
    if (setStatus.RunMode == RUN_MODE_AUTO) {
        [modeview setImage:[UIImage imageNamed:@"staauto.png"]];
    }
    if (setStatus.FanSpeed == FAN_SPEED_MIN) {
        [fanview setImage:[UIImage imageNamed:@"staslow.png"]];
    }
    if (setStatus.FanSpeed > FAN_SPEED_MIN
        & setStatus.FanSpeed < FAN_SPEED_MAX) {
        [fanview setImage:[UIImage imageNamed:@"stacenter.png"]];
    }
    if (setStatus.FanSpeed == FAN_SPEED_MAX) {
        [fanview setImage:[UIImage imageNamed:@"stastrong.png"]];
    }
    if (setStatus.FanScan == FAN_FIX) {
        [fixview setImage:[UIImage imageNamed:@"stafix.png"]];
    }
    if (setStatus.FanScan == FAN_SCAN) {
        [fixview setImage:[UIImage imageNamed:@"stascan.png"]];
    }

}

 -(BOOL) CheckSameStatus {
    if (setStatus.SetTemp != dkStatus.SetTemp)
        return NO;
    if (setStatus.Power != dkStatus.Power)
        return NO;
    if (setStatus.RunMode != dkStatus.RunMode)
        return NO;
    if (setStatus.FanScan != dkStatus.FanScan)
        return NO;
    if (setStatus.FanSpeed != dkStatus.FanSpeed)
        return NO;
    return YES;
}

-(BOOL) CheckControl {
    if (dkStatus.SetTemp != setStatus.SetTemp)
        return YES;
    if (dkStatus.Power != setStatus.Power)
        return YES;
    if (dkStatus.RunMode != setStatus.RunMode)
        return YES;
    if (dkStatus.FanScan != setStatus.FanScan)
        return YES;
    if (dkStatus.FanSpeed != setStatus.FanSpeed)
        return YES;
    return NO;
}

- (IBAction)modePressed : (id)sender{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case 101:
            setStatus.RunMode=RUN_MODE_COLD;
            [modeview setImage:[UIImage imageNamed:@"stacold.png"]];
            break;
        case 102:
             setStatus.RunMode=RUN_MODE_HEAT;
            [modeview setImage:[UIImage imageNamed:@"staheat.png"]];
            break;
        case 103:
             setStatus.RunMode=RUN_MODE_DRY;
            [modeview setImage:[UIImage imageNamed:@"stadehu.png"]];
            break;
        case 104:
             setStatus.RunMode=RUN_MODE_FAN;
            [modeview setImage:[UIImage imageNamed:@"stafan.png"]];
            break;
        default:
            break;
    }
    s_bNeedWrite = true;
}

-(IBAction)fanPressed :(id)sender{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case 302:
            setStatus.FanSpeed=FAN_SPEED_MIN;
            [fanview setImage:[UIImage imageNamed:@"staslow.png"]];
            break;
        case 303:
            setStatus.FanSpeed=3;
            [fanview setImage:[UIImage imageNamed:@"stacenter.png"]];
            break;
        case 304:
            setStatus.FanSpeed=FAN_SPEED_MAX;
            [fanview setImage:[UIImage imageNamed:@"stastrong.png"]];
            break;
        default:
            break;
    }
    s_bNeedWrite = true;
}
- (IBAction)tmpPressed : (id)sender{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case 201:
            setStatus.SetTemp = setStatus.SetTemp + 1;
            break;
        case 202:
            setStatus.SetTemp = setStatus.SetTemp - 1;
            break;
        default:
            break;
    }
    if (setStatus.SetTemp<16) {
        setStatus.SetTemp=16;
    }if (setStatus.SetTemp>32) {
        setStatus.SetTemp=32;
    }
    slider.value=setStatus.SetTemp-16;
    NSString *tmpstr=[[NSString alloc] initWithFormat:@"set%d.png",setStatus.SetTemp];
    [settmpview setImage:[UIImage imageNamed:tmpstr]];
     s_bNeedWrite = true;
}
- (IBAction)tmpSwip : (id)sender{
   // NSLog(@"tmpval:%f",slider.value*2);
    setStatus.SetTemp=(int)(slider.value)+16;
    NSString *tmpstr=[[NSString alloc] initWithFormat:@"set%d.png",setStatus.SetTemp];
    [settmpview setImage:[UIImage imageNamed:tmpstr]];
     s_bNeedWrite = true;
}

- (IBAction)fixPressed : (id)sender{
    if (setStatus.FanScan==FAN_SCAN) {
        setStatus.FanScan=FAN_FIX;
         [fixview setImage:[UIImage imageNamed:@"stafix.png"]];
    }else{
        setStatus.FanScan=FAN_SCAN;
        [fixview setImage:[UIImage imageNamed:@"stascan.png"]];
    }
    s_bNeedWrite = true;
}
- (IBAction)powerPressed : (id)sender{
    if (setStatus.Power==0) {
        setStatus.Power = 1;
        [onoffview setImage:[UIImage imageNamed:@"sta_on.png"]];
        [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg_press.png"] forState:UIControlStateNormal];
   }else{
        setStatus.Power =0;
        [onoffview setImage:[UIImage imageNamed:@"sta_off.png"]];
       [powerbtn setBackgroundImage: [UIImage imageNamed:@"operation_page_indoor_data_show_bottom_bg.png"] forState:UIControlStateNormal];
    }
    s_bNeedWrite = true;
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    bFirstRun = true;
    setStatus.Timer = 0;
    bNeeRead = true;
    boolRunning = true;
    [self.airtimer setFireDate:[NSDate distantPast]];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
     boolRunning = false;
    [self.airtimer setFireDate:[NSDate distantFuture]];
    [udpSocket close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    boolRunning = false;
    [self.airtimer setFireDate:[NSDate distantFuture]];
    [udpSocket close];
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
