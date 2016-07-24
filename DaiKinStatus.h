//
//  DaiKinStatus.h
//  InCloud
//
//  Created by Denis on 15/7/21.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaiKinStatus : NSObject<NSCoding>{
    NSInteger SetTemp;
    NSInteger RoomTemp;
    NSInteger Power;
    NSInteger RunMode;
    NSInteger FanScan;
    NSInteger FanSpeed;
    NSInteger Timer ;
}
@property NSInteger SetTemp;
@property NSInteger RoomTemp;
@property NSInteger Power;
@property NSInteger RunMode;
@property NSInteger FanScan;
@property NSInteger FanSpeed;
@property NSInteger Timer;
@end
