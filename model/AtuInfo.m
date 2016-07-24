//
//  AtuInfo.m
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "AtuInfo.h"

@implementation AtuInfo
@synthesize atuId;
@synthesize atuCode;
@synthesize atuName;
@synthesize atuIp;
@synthesize atuPwd;
@synthesize atuRemoIp;
@synthesize atuRemoPort;
@synthesize atuRoom;
@synthesize isRemote;


- (void)encodeWithCoder:(NSCoder *)aCoder{
     [aCoder encodeObject:atuId forKey:@"atuId"];
    [aCoder encodeObject:atuCode forKey:@"atuCode"];
    [aCoder encodeObject:atuName forKey:@"atuName"];
    [aCoder encodeObject:atuIp forKey:@"atuIp"];
    [aCoder encodeObject:atuPwd forKey:@"atuPwd"];
    [aCoder encodeObject:atuRemoIp forKey:@"atuRemoIp"];
    [aCoder encodeInteger:atuRemoPort forKey:@"atuRemoPort"];
    [aCoder encodeObject:atuRoom forKey:@"atuRoom"];
    [aCoder encodeInteger:isRemote forKey:@"isRemote"];
    [aCoder encodeBool:expand forKey:@"expand"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
       atuId= [aDecoder decodeObjectForKey:@"atuId"] ;
    atuCode= [aDecoder decodeObjectForKey:@"atuCode"] ;
    atuRemoPort= [aDecoder decodeIntegerForKey:@"atuRemoPort"];
    isRemote= [aDecoder decodeIntegerForKey:@"isRemote"];
    atuName= [aDecoder decodeObjectForKey:@"atuName"];
    atuIp= [aDecoder decodeObjectForKey:@"atuIp"];
    atuPwd= [aDecoder decodeObjectForKey:@"atuPwd"];
    atuRemoIp= [aDecoder decodeObjectForKey:@"atuRemoIp"];
    atuRoom= [aDecoder decodeObjectForKey:@"atuRoom"];
    expand=[aDecoder decodeBoolForKey:@"expand"];
    return self;
}

-(NSDictionary*)fetchInDictionaryForm
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:atuId forKey:@"atuId"];
    [dict setObject:atuCode forKey:@"atuCode"];
    [dict setObject:[NSNumber numberWithInt:atuRemoPort] forKey:@"atuRemoPort"];
    [dict setObject:[NSNumber numberWithInt:isRemote] forKey:@"isRemote"];
    [dict setObject:atuName forKey:@"atuName"];
     [dict setObject:atuIp forKey:@"atuIp"];
     [dict setObject:atuPwd forKey:@"atuPwd"];
    if (atuRemoIp==nil) {
        [dict setObject:@"" forKey:@"atuRemoIp"];
    }else{
        [dict setObject:atuRemoIp forKey:@"atuRemoIp"];
    }
    [dict setObject:[NSNumber numberWithBool:expand]forKey:@"expand"];
    
     [dict setObject:atuRoom forKey:@"atuRoom"];
    return dict;
}
@end
