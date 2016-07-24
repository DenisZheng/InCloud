//
//  SecneTableViewCell.m
//  InCloud
//
//  Created by Denis on 15/7/29.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "SecneTableViewCell.h"

#import "Constants.h"
#import "CMDService.h"
#import "ConfigService.h"

@implementation SecneTableViewCell
@synthesize onbtn,offbtn,coldbtn,heatbtn,dehubtn,fanbtn,lowbtn,centerbtn,strongbtn,fixbtn,scanbtn,templbl,tempslider,savebtn,calbtn;
- (void)awakeFromNib {
    // Initialization code
    onbtn.selected=YES;
    coldbtn.selected=YES;
    lowbtn.selected=YES;
    fixbtn.selected=YES;
    tempslider.value=24.0f/2;
    templbl.text=@"24";
    Reqflag=-1;
    setStatus=[DaiKinStatus new];
    dkStatus=[DaiKinStatus new];
    [tempslider addTarget:self action:@selector(tmpSwip) forControlEvents:UIControlEventValueChanged];
     self.selectionStyle =UITableViewCellSelectionStyleNone;
}

- (void)tmpSwip{
    // NSLog(@"tmpval:%f",slider.value*2);
    setStatus.SetTemp=(int)(tempslider.value)+16;
    templbl.text=[[NSString alloc] initWithFormat:@"%d",setStatus.SetTemp];
}

-(void)initCell:(AtuInfo *)atu{
    dev=atu;
    [self creatSocket];
    CMDService *cs=[[CMDService alloc] init];
    cs.atuId=atu.atuId;
    cs.atupwd=atu.atuPwd;
    NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@%@,",ATU_CMD_RDSCENE,@"一键开启"];
    NSData *data = [cs InCloudCommand:cmdstr];
    [sendUdpSocket sendData:data toHost:atu.atuIp port:9559 withTimeout:60 tag:200];
    Reqflag=1;
    [sendUdpSocket receiveOnce:nil];

}

-(void)creatSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("secne udp socket", NULL);
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [sendUdpSocket setIPv4Enabled:YES];
    [sendUdpSocket setIPv6Enabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Helpers

- (IBAction)logSelectedButton:(DLRadioButton *)radiobutton {
    //NSLog(@"%@ is selected.valeu is %ld\n", radiobutton.selectedButton.titleLabel.text,(long)radiobutton.selectedButton.tag);
    switch (radiobutton.selectedButton.tag) {
        case 101:
            setStatus.Power=1;
            break;
        case 102:
            setStatus.Power=0;
            break;
        case 201:
            setStatus.RunMode=RUN_MODE_COLD;
            break;
        case 202:
            setStatus.RunMode=RUN_MODE_HEAT;
            break;
        case 203:
            setStatus.RunMode=RUN_MODE_DRY;
            break;
        case 204:
            setStatus.RunMode=RUN_MODE_FAN;
            break;
        case 301:
            setStatus.FanSpeed=FAN_SPEED_MIN;
            break;
        case 302:
            setStatus.FanSpeed=3;
            break;
        case 303:
            setStatus.FanSpeed=FAN_SPEED_MAX;
            break;
        case 401:
            setStatus.FanScan=FAN_FIX;
            break;
        case 402:
            setStatus.FanScan=FAN_SCAN;
            break;
        default:
            break;
    }
}

- (IBAction)savePressed : (id)sender{
    [self creatSocket];
    CMDService *cs=[[CMDService alloc] init];
    cs.atuId=dev.atuId;
    cs.atupwd=dev.atuPwd;
    NSString *cmdstr=[[NSString alloc] initWithFormat:@"%@一键开启:%@,%@,%@;",ATU_CMD_WRSCENE,dev.atuRoom,dev.atuName,[cs BuildDataString:setStatus]];
    NSData *data = [cs InCloudCommand:cmdstr];
    [sendUdpSocket sendData:data toHost:dev.atuIp port:9559 withTimeout:60 tag:200];
    Reqflag=2;
    [sendUdpSocket receiveOnce:nil];
}
- (IBAction)calPressed : (id)sender{
    
}

#pragma mark -GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContex
{
    
    //取得发送发的ip和端口
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    //data就是接收的数据
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *revstr = [[NSString alloc] initWithData: data encoding:strEncode];
    
    
    NSLog(@"[%@:%u]%@",ip, port,revstr);
   if([revstr hasPrefix:@"Command="]&&Reqflag==1){
       NSArray *array = [revstr componentsSeparatedByString:@";"];
       NSString *str1=[array objectAtIndex:0];
       NSArray *strValue=[str1 componentsSeparatedByString:@","];
       dkStatus.SetTemp = strtoul([[strValue objectAtIndex:2] UTF8String],0,16);
       dkStatus.Power = strtoul([[strValue objectAtIndex:3] UTF8String],0,16);
       dkStatus.RunMode = strtoul([[strValue objectAtIndex:4] UTF8String],0,16);
       dkStatus.FanSpeed = strtoul([[strValue objectAtIndex:5] UTF8String],0,16)>> 4;
       dkStatus.FanScan = strtoul([[strValue objectAtIndex:5] UTF8String],0,16) & 0x0F;
       setStatus.SetTemp = strtoul([[strValue objectAtIndex:2] UTF8String],0,16);
       setStatus.Power = strtoul([[strValue objectAtIndex:3] UTF8String],0,16);
       setStatus.RunMode = strtoul([[strValue objectAtIndex:4] UTF8String],0,16);
       setStatus.FanSpeed = strtoul([[strValue objectAtIndex:5] UTF8String],0,16)>> 4;
       setStatus.FanScan = strtoul([[strValue objectAtIndex:5] UTF8String],0,16) & 0x0F;
       dispatch_async(dispatch_get_main_queue(),^{
           templbl.text=[[NSString alloc] initWithFormat:@"%d",dkStatus.SetTemp];
           tempslider.value=dkStatus.SetTemp/2;
           if (dkStatus.Power==0) {
               offbtn.selected=YES;
           }else{
               onbtn.selected=YES;
           }
           if (dkStatus.RunMode == RUN_MODE_COLD) {
               coldbtn.selected=YES;
           }
           if (dkStatus.RunMode == RUN_MODE_HEAT) {
               heatbtn.selected=YES;
           }
           if (dkStatus.RunMode == RUN_MODE_FAN) {
               fanbtn.selected=YES;
           }
           if (dkStatus.RunMode == RUN_MODE_DRY) {
               dehubtn.selected=YES;
           }
           if (dkStatus.FanSpeed == FAN_SPEED_MIN) {
               lowbtn.selected=YES;
           }
           if (dkStatus.FanSpeed > FAN_SPEED_MIN
               & dkStatus.FanSpeed < FAN_SPEED_MAX) {
               centerbtn.selected=YES;
           }
           if (dkStatus.FanSpeed == FAN_SPEED_MAX) {
               strongbtn.selected=YES;
           }
           if (dkStatus.FanScan == FAN_FIX) {
               fixbtn.selected=YES;
           }
           if (dkStatus.FanScan == FAN_SCAN) {
               scanbtn.selected=YES;
           }

       });
       Reqflag=-1;
       [sendUdpSocket close];
   }if([revstr hasPrefix:@"Command="]&&Reqflag==2){
       NSLog(@"wrsecne success");
       Reqflag=-1;
       [sendUdpSocket close];
   }
    
}

@end
