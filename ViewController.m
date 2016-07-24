//
//  ViewController.m
//  InCloud
//
//  Created by Denis on 15/7/3.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "ConfigService.h"
#import "service/CMDService.h"
#import "model/AtuInfo.h"
#import "AFNetworking/AFNetworking.h"
#import "MyIPHelper.h"
#import "Socket/SocketOperaters.h"
@implementation ViewController{
    ConfigService *cs;
    __block NSInteger networksta;
}
//  NSInteger const LAN_CTR_MODE = 0;
//  NSInteger const  REMO_CTR_MODE = 1;
//  NSInteger const  SLOW_CTR_MODE = 2;
//  NSInteger const  ERR_CTR_MODE = -1;
@synthesize atus,mytimer,mytable;
- (void)viewDidLoad {
    [super viewDidLoad];
    cs=[[ConfigService alloc] init];
    atus=[cs LoadAtusData];
//    if([atus count]==0){
//        AtuInfo *atu=[AtuInfo new];
//        atu.atuId=@"001204011DA0";
//        atu.atuCode=@"001204011DA0";
//        atu.atuName=@"大金空调";
//        atu.atuRoom=@"客厅";
//        atu.atuPwd=@"001204011DA0";
//        atu.atuIp=@"192.168.100.1";
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:atu];
//        [atus addObject:data];
//        [cs SaveAtusData:atus];
//    }
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {
                NSLog(@"AFNetworkReachabilityStatusUnknown");
                networksta=-1;
                dispatch_async(dispatch_get_main_queue(),^{
                    
                   UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"未知网络，请检查网络！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                });
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"AFNetworkReachabilityStatusNotReachable");
                networksta=-1;
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"提示" message:@"网络未连接，请检查网络！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                });
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");
                networksta=2;
                dispatch_async(dispatch_get_main_queue(),^{
                    
                });
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");
                networksta=1;
                dispatch_async(dispatch_get_main_queue(),^{
                    
                });
                break;
            }
            default: {
                break;
            }
        }
    }];
    [manager startMonitoring];
    
    mytimer =  [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(InitAtuSta) userInfo:nil repeats:YES];
    
}





-(void)InitAtuSta{
    if([atus count]>0){
        __block CMDService *cmd=[CMDService new];
        __block SocketOperaters *so=[[SocketOperaters alloc] init];
        for (int i=0;i<[atus count];i++) {
            NSData *data=[atus objectAtIndex:i];
            AtuInfo *atu=[NSKeyedUnarchiver unarchiveObjectWithData:data];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *senddata = [cmd FindAtuCommand:atu.atuId];
                NSString *rev=[so ReadSend:[MyIPHelper boardcastIPAdress] AtuPort:9559 SendData:senddata];
                if ([rev length]==0) {//局域网不通
                     NSString *usrName=[cs GetLoginName];
                     NSString *usrpwd=[cs GetPwd];
                    if (([usrName length]==0)||([usrName isEqualToString:@"admin"])) {
                        //未远程,设笽不在线
                        atu.isRemote=ERR_CTR_MODE;
                    }else{
                        NSString *revstr=[cs RemLogin:usrName Pwd:usrpwd Serial:atu.atuId];
                        if ([revstr length]!=0) {
                            //远程连接成功
                            NSArray *array = [revstr componentsSeparatedByString:@":"];
                            NSString *remIP=[array objectAtIndex:0];
                            NSString *remPort=[array objectAtIndex:1];
                            NSString *remrev=[so ReadSend:remIP AtuPort:[remPort intValue] SendData:senddata];
                            if ([remrev length]==0) {
                                //远程设笽不在线，判断慢速模式
                                NSString *slowrev=[cs RemControl:usrName Pwd:usrpwd Serial:atu.atuId AirPass:atu.atuPwd CMD:@""];
                                if ([slowrev length]!=0) {
                                    //慢速模式
                                    atu.isRemote=SLOW_CTR_MODE;
                                }else{
                                    //慢速模式失败，不在线
                                    atu.isRemote=ERR_CTR_MODE;
                                }
                            }else{
                                //远程模式
                                atu.isRemote=REMO_CTR_MODE;
                                atu.atuRemoIp=remIP;
                                atu.atuRemoPort=[remPort intValue];
                            }
                        }else{
                            //远程连接失败
                            atu.isRemote=ERR_CTR_MODE;
                        }
                    }
                }else{//局域网模式
                    NSLog(@"lan ip:%@",rev);
                    atu.atuIp=rev;
                    atu.isRemote=LAN_CTR_MODE;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    NSLog(@"realod....");
                    [self UpdateAtus:atu];
                    [self.mytable reloadData];
                });  
                
            });
        }
    }
}

-(void) UpdateAtus:(AtuInfo *)atu {
    if ([atus count]>0) {
        for (int  i=0; i<[atus count]; i++) {
            NSData *data=[atus objectAtIndex:i];
            AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([dev.atuId isEqualToString:atu.atuId]) {
                dev.atuRemoIp=atu.atuRemoIp;
                dev.atuRemoPort=atu.atuRemoPort;
                dev.atuIp=atu.atuIp;
                dev.isRemote=atu.isRemote;
                NSData *devdata=[NSKeyedArchiver archivedDataWithRootObject:dev];
                [atus replaceObjectAtIndex:i withObject:devdata];
                break;
            }
        }
        [cs SaveAtusData:atus];
    }

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [atus count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    cell.selectionStyle= UITableViewCellStyleDefault;
    NSData *data=[atus objectAtIndex:indexPath.row];
    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    UIImage *icon = [UIImage imageNamed:@ "icon_air_on.png" ];
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   

    cell.tag=indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", dev.atuRoom,dev.atuName];
    UIImageView *imageView = [[UIImageView alloc] init];
    switch (dev.isRemote) {
        case -1://ERR_CTR_MODE
           imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"offline.png"]];
            cell.accessoryView=imageView;
            break;
        case 0: //LAN_CTR_MODE:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
            cell.accessoryView=imageView;
            break;
        case 1://REMO_CTR_MODE:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cloud.png"]];
            cell.accessoryView=imageView;
            break;
        case 2://SLOW_CTR_MODE:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_low.png"]];
            cell.accessoryView=imageView;
            break;
        default:
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"offline.png"]];
            cell.accessoryView=imageView;
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

//    NSData *data=[atus objectAtIndex:indexPath.row];
//    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atus removeObjectAtIndex:indexPath.row];
    [cs SaveAtusData:atus];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"删除";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
}


//#pragma mark -GCDAsyncUdpSocketDelegate
//-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContex{
//    //取得发送发的ip和端口
//    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
//    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
//    //data就是接收的数据
//    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *s = [[NSString alloc] initWithData: data encoding:strEncode];
//    if (s)
//    {
//        NSLog(@"[%@:%u]%@",ip, port,s);
//    }
//    else
//    {
//        NSLog(@"Error converting received data into UTF-8 String");
//    }
//   
//}
//
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
//    
//    NSLog(@"tag:%ld,%@",tag, error);
//}
//
//-(void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
//    NSLog(@"Socket closed, error: %@", error);
//}
//
//
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
//    NSLog(@"Socket send, tag: %ld", tag);
//}
//
//-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
//    NSLog(@"Failed to connect to host, error: %@", error);
//}



//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    //开启定时器
    NSLog(@"qiangtai")  ;
    cs=[[ConfigService alloc] init];
    atus=[cs LoadAtusData];
    [self.mytable reloadData];
    [self.mytimer setFireDate:[NSDate distantPast]];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void)viewDidDisappear:(BOOL)animated
{
    //关闭定时器
     NSLog(@"houtai")  ;
    [self.mytimer setFireDate:[NSDate distantFuture]];
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UITableViewCell *cell = (UITableViewCell*) sender;
     //NSLog(@"==========%i",cell.tag);
     NSData *data=[atus objectAtIndex:cell.tag];
     AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
     UIViewController* view = segue.destinationViewController;
     //if ([view respondsToSelector:@selector(setParam:)]) {
         [view setValue:dev forKey:@"atu"];
     //}
 }


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    UITableViewCell *cell = (UITableViewCell*) sender;
    NSData *data=[atus objectAtIndex:cell.tag];
    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (dev.isRemote==ERR_CTR_MODE) {
                return NO;
     }
     return YES;
}

- (void)didReceiveMemoryWarning {
    //取消定时器
    [self.mytimer invalidate];
    self.mytimer = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
