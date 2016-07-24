//
//  Constants.m
//  InCloud
//
//  Created by Denis on 15/7/8.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "Constants.h"
//全局常量
@implementation Constants
 NSString * const ATU_CMD_FIND=@"FindAtu,";
 NSString * const ATU_CMD_LOGIN=@"LoginAtu,";
 NSString * const ATU_CMD_INCLOUD=@"InCloud,";
 NSString * const ATU_CMD_NMROOM=@"nmRoom,";
 NSString * const ATU_CMD_WPA=@"network={";
 NSString * const ATU_CMD_NETWORK=@"SetNetwork:";
 NSString * const ATU_CMD_GETROOM=@"getRooms,";
 NSString * const ATU_CMD_RDROOM=@"rdRoom,";
 NSString * const ATU_CMD_WRROOM=@"wrRoom,";
NSString *const ATU_CMD_WRSCENE =@"wrScene,";
NSString *const ATU_CMD_GETSCENES = @"getScenes,";
NSString *const ATU_CMD_RDSCENE = @"rdScene,";
NSString *const ATU_CMD_DELSCENE = @"delScene,";
 NSString *const ATU_CTR_SLOW=@"SLOW";
 NSInteger const TEMP_MAX=32;
 NSInteger const TEMP_MIN=16 ;
 NSInteger const FAN_SPEED_MIN=1 ;
 NSInteger const FAN_SPEED_MAX=5 ;
 NSInteger const FAN_SCAN=7 ;
 NSInteger const FAN_FIX=1 ;
 NSInteger const RUN_MODE_FAN =0x60;
 NSInteger const RUN_MODE_HEAT=0x61 ;
 NSInteger const RUN_MODE_COLD=0x62 ;
 NSInteger const RUN_MODE_AUTO=0x63 ;
 NSInteger const RUN_MODE_DRY =0x67;
 NSString *const CMD_GET_DATA = @"rdRoom,";
 NSString *const CMD_SET_DATA = @"wrRoom,";
 NSString *const CMD_SCENE = @"Scene,";
 NSInteger const  LAN_CTR_MODE = 0;
 NSInteger const  REMO_CTR_MODE = 1;
 NSInteger const  SLOW_CTR_MODE = 2;
 NSInteger const  ERR_CTR_MODE = -1;
@end
