//
//  CMDService.m
//  InCloud
//
//  Created by Denis on 15/7/8.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "CMDService.h"
#import "Constants.h"
@implementation CMDService
@synthesize atuId,atupwd;

-(NSData *)InCloudCommand:(NSString *)StrCommand{
    NSString *cmd;
    cmd=[ATU_CMD_INCLOUD stringByAppendingFormat:@"%@,admin_%@,%@",atuId,atupwd,StrCommand];
    NSLog(@"InCloudCmd:%@",cmd);
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *cmddata = [cmd dataUsingEncoding:strEncode];
    return cmddata;
}

-(NSData *)FindAtuCommand:(NSString *)AtuId{
    NSString *cmd;
    cmd=[ATU_CMD_FIND stringByAppendingFormat:@"%@,",AtuId];
    NSLog(@"FindCmd:%@",cmd);
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *cmddata = [cmd dataUsingEncoding:strEncode];
    return cmddata;
}

-(NSString *)BuildDataString:(DaiKinStatus *)status{
    NSString *cmd;
    cmd=[[NSString alloc] initWithFormat:@"%02X,",status.SetTemp];
    if (status.Power==1) {
        cmd=[cmd stringByAppendingFormat:@"01,"];
    }else{
        cmd=[cmd stringByAppendingFormat:@"00,"];
    }
     cmd=[cmd stringByAppendingFormat:@"%02X,",status.RunMode];
    NSInteger fan=(status.FanSpeed << 4) & 0xF0;
    fan |= status.FanScan & 0x0F;
    fan &= 0xFF;
    cmd=[cmd stringByAppendingFormat:@"%02X,",fan];
    return cmd;
}
@end
