//
//  DaiKinStatus.m
//  InCloud
//
//  Created by Denis on 15/7/21.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "DaiKinStatus.h"

@implementation DaiKinStatus
@synthesize SetTemp,RoomTemp,Power,RunMode,FanScan,FanSpeed,Timer;

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeInteger:SetTemp forKey:@"SetTemp"];
    [aCoder encodeInteger:RoomTemp forKey:@"RoomTemp"];
     [aCoder encodeInteger:Power forKey:@"Power"];
     [aCoder encodeInteger:RunMode forKey:@"RunMode"];
     [aCoder encodeInteger:FanScan forKey:@"FanScan"];
     [aCoder encodeInteger:FanSpeed forKey:@"FanSpeed"];
    [aCoder encodeInteger:Timer forKey:@"Timer"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{

    SetTemp= [aDecoder decodeIntegerForKey:@"SetTemp"];
    RoomTemp= [aDecoder decodeIntegerForKey:@"RoomTemp"];
    Power= [aDecoder decodeIntegerForKey:@"Power"];
    RunMode= [aDecoder decodeIntegerForKey:@"RunMode"];
    FanScan= [aDecoder decodeIntegerForKey:@"FanScan"];
    FanSpeed= [aDecoder decodeIntegerForKey:@"FanSpeed"];
    Timer= [aDecoder decodeIntegerForKey:@"Timer"];
    return self;
}
@end
