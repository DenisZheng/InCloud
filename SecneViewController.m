//
//  SecneViewController.m
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "SecneViewController.h"
#import "ConfigService.h"
#import "Constants.h"
#import "service/CMDService.h"
#import "model/AtuInfo.h"
#import "SecneTableViewCell.h"
@interface SecneViewController (){
    ConfigService *cs;
    CMDService *Dakin;
    NSString *cmdstr;
    NSInteger Reqflag;
    NSString *secneIp;
    NSInteger secneport;
}
@property (nonatomic) NSIndexPath *expandingIndexPath;
@property (nonatomic) NSIndexPath *expandedIndexPath;


- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath;
//- (void)createDataSourceArray;
@end

@implementation SecneViewController
@synthesize atus,mytable;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cs=[[ConfigService alloc] init];
    atus=[cs LoadAtusData];
      Dakin =[[CMDService alloc] init];
    Reqflag=-1;
}

-(void)creatSocket{
    dispatch_queue_t dQueue = dispatch_queue_create("execu sence udp socket", NULL);
    sendUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    [sendUdpSocket setIPv4Enabled:YES];
    [sendUdpSocket setIPv6Enabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated
{
    cs=[[ConfigService alloc] init];
    atus=[cs LoadAtusData];
    [self.mytable reloadData];
}


#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.expandedIndexPath) {
        return [atus count] + 1;
    }
    
    return [atus count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = nil;
    // init expanded cell
    if ([indexPath isEqual:self.expandedIndexPath]) {
        SecneTableViewCell *cell = nil;
        cellIdentifier = @"ExpandedCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                               forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SecneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier];
        }
        [cell.savebtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [cell.calbtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [cell.savebtn setTag:900+indexPath.row];
        NSData *data=[atus objectAtIndex:indexPath.row-1];
        AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        [cell initCell:dev];
        return cell;
    }
    // init expanding cell
    else {
        UITableViewCell *cell = nil;
        cellIdentifier = @"ExpandingCellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                               forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier];
        }
        NSIndexPath *theIndexPath = [self actualIndexPathForTappedIndexPath:indexPath];
        NSData *data=[atus objectAtIndex:indexPath.row];
        AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        UIImage *icon = [UIImage imageNamed:@ "general_dining_icon.png" ];
        CGSize itemSize = CGSizeMake(60, 60);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [icon drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        cell.tag=indexPath.row;
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", dev.atuRoom,@"一键开启"];
        return cell;
    }

}

-(void)action:(UIButton *)sender{
    CGRect buttonRect = sender.frame;
    for (SecneTableViewCell *cell in [mytable visibleCells])
    {
        if (CGRectIntersectsRect(buttonRect, cell.frame))
        {
            //cell就是所要获得的
            NSIndexPath *cellindexPath=[mytable indexPathForCell:cell];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellindexPath.row-1 inSection:0];
            //NSLog(@"cell row is %d",indexpath.row);
            UITableViewCell *percell = [mytable cellForRowAtIndexPath:indexPath];
            if ([[percell reuseIdentifier] isEqualToString:@"ExpandedCellIdentifier"]) {
                return;
            }

            [mytable deselectRowAtIndexPath:indexPath
                                     animated:NO];
            
            // get the actual index path
            indexPath = [self actualIndexPathForTappedIndexPath:indexPath];
            
            // save the expanded cell to delete it later
            NSIndexPath *theExpandedIndexPath = self.expandedIndexPath;
            self.expandingIndexPath = nil;
            self.expandedIndexPath = nil;
            
            [mytable beginUpdates];
            
            if (theExpandedIndexPath) {
                // [mytable.dataSource removeObjectAtIndex:indexPath.row];
                [mytable deleteRowsAtIndexPaths:@[theExpandedIndexPath]
                               withRowAnimation:UITableViewRowAnimationNone];
            }
            
            [mytable endUpdates];
            
            // scroll to the expanded cell
            [self.mytable scrollToRowAtIndexPath:indexPath
                                atScrollPosition:UITableViewScrollPositionMiddle
                                        animated:YES];
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.expandedIndexPath]) {
        
        return 266;
    }else{
        
        return 60;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![indexPath isEqual:self.expandedIndexPath]) {
       NSData *data=[atus objectAtIndex:indexPath.row];
       AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
       [self creatSocket];
       Dakin.atuId=dev.atuId;
       Dakin.atupwd=dev.atuPwd;
        if (dev.isRemote==LAN_CTR_MODE) {
            secneIp=[[NSString alloc]initWithFormat:@"%@",dev.atuIp];
            secneport=9559;
        }else if(dev.isRemote==REMO_CTR_MODE){
            secneIp=[[NSString alloc]initWithFormat:@"%@",dev.atuRemoIp];
            secneport=dev.atuRemoPort;
        }
        
       NSString *datastr=[[NSString alloc] initWithFormat:@"%@一键开启,",ATU_CMD_RDSCENE];
       NSData *cmddata = [Dakin InCloudCommand:datastr];
       Reqflag=1;
      [sendUdpSocket sendData:cmddata toHost:secneIp port:secneport withTimeout:60 tag:200];
      [sendUdpSocket receiveOnce:nil];
    }
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.expandedIndexPath]) {
        
    }else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([[cell reuseIdentifier] isEqualToString:@"ExpandedCellIdentifier"]) {
            return;
        }
        
        // deselect row
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:NO];
        
        // get the actual index path
        indexPath = [self actualIndexPathForTappedIndexPath:indexPath];
        
        // save the expanded cell to delete it later
        NSIndexPath *theExpandedIndexPath = self.expandedIndexPath;
        
        // same row tapped twice - get rid of the expanded cell
        if ([indexPath isEqual:self.expandingIndexPath]) {
            self.expandingIndexPath = nil;
            self.expandedIndexPath = nil;
        }
        // add the expanded cell
        else {
            self.expandingIndexPath = indexPath;
            self.expandedIndexPath = [NSIndexPath indexPathForRow:[indexPath row] + 1
                                                        inSection:[indexPath section]];
        }
        
        [tableView beginUpdates];
        
        if (theExpandedIndexPath) {
            [mytable deleteRowsAtIndexPaths:@[theExpandedIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            
        }
        if (self.expandedIndexPath) {
            [mytable insertRowsAtIndexPaths:@[self.expandedIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [tableView endUpdates];
        
        // scroll to the expanded cell
        [self.mytable scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:UITableViewScrollPositionMiddle
                                         animated:YES];
        [mytable reloadData];
    }

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.expandedIndexPath]) {
        return UITableViewCellEditingStyleNone;
    }return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.expandedIndexPath]) {
        return nil;
    }else{
        return @"设置" ;
    }
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


#pragma mark - controller methods



- (NSIndexPath *)actualIndexPathForTappedIndexPath:(NSIndexPath *)indexPath
{
    if (self.expandedIndexPath && [indexPath row] > [self.expandedIndexPath row]) {
        return [NSIndexPath indexPathForRow:[indexPath row] - 1
                                  inSection:[indexPath section]];
    }
    
    return indexPath;
}


#pragma mark -GCDAsyncUdpSocketDelegate
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContex{
    //取得发送发的ip和端口
    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    //data就是接收的数据
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *revstr = [[NSString alloc] initWithData: data encoding:strEncode];
    NSLog(@"[%@:%u]%@",ip, port,revstr);
    if (revstr)
    {
        
        if([revstr hasPrefix:@"Command="]&&Reqflag==1){
            NSArray *array = [revstr componentsSeparatedByString:@";"];
            NSString *str1=[array objectAtIndex:0];
            NSArray *strValue=[str1 componentsSeparatedByString:@"="];
            cmdstr=[strValue objectAtIndex:1];
            NSString *datastr=[[NSString alloc] initWithFormat:@"%@%@",CMD_SET_DATA,cmdstr];
            NSData *cmddata = [Dakin InCloudCommand:datastr];
            Reqflag=2;
            [sendUdpSocket sendData:cmddata toHost:secneIp port:secneport withTimeout:60 tag:200];
            [sendUdpSocket receiveOnce:nil];
            revstr=@"";
        }
        if([revstr hasPrefix:@"Command="]&&Reqflag==2){
            NSLog(@"send success");
            Reqflag=-1;
            [sendUdpSocket close];
            revstr=@"";
        }
    }
    else
    {
        NSLog(@"Error converting received data into UTF-8 String");
    }

}







- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
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
