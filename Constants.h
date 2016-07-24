//
//  Constants.h
//  InCloud
//
//  Created by Denis on 15/7/8.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
extern NSString * const ATU_CMD_FIND;
extern NSString * const ATU_CMD_LOGIN;
extern NSString * const ATU_CMD_INCLOUD;
extern NSString * const ATU_CMD_NMROOM;
extern NSString * const ATU_CMD_WPA;
extern NSString * const ATU_CMD_NETWORK;
extern NSString * const ATU_CMD_GETROOM;
extern NSString * const ATU_CMD_RDROOM;
extern NSString * const ATU_CMD_WRDROOM;
extern NSInteger const TEMP_MAX;
extern NSInteger const TEMP_MIN ;
extern NSInteger const FAN_SPEED_MIN ;
extern NSInteger const FAN_SPEED_MAX ;
extern NSInteger const FAN_SCAN ;
extern NSInteger const FAN_FIX ;
extern NSInteger const RUN_MODE_FAN ;
extern NSInteger const RUN_MODE_HEAT ;
extern NSInteger const RUN_MODE_COLD ;
extern NSInteger const RUN_MODE_AUTO ;
extern NSInteger const RUN_MODE_DRY ;
extern NSString *const ATU_CTR_SLOW;
extern NSString *const CMD_GET_DATA;
extern NSString *const CMD_SET_DATA;
extern NSString *const CMD_SCENE;
extern NSInteger const  LAN_CTR_MODE;
extern NSInteger const  REMO_CTR_MODE;
extern NSInteger const  SLOW_CTR_MODE;
extern NSInteger const  ERR_CTR_MODE;
extern NSString  *const ATU_CMD_WRSCENE;
extern NSString *const ATU_CMD_GETSCENES;
extern NSString *const ATU_CMD_RDSCENE;
extern NSString *const ATU_CMD_DELSCENE;
@end
