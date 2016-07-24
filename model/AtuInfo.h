//
//  AtuInfo.h
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AtuInfo : NSObject<NSCoding>{
    NSString *atuId;
    NSString *atuCode;
    NSString *atuName;
    NSString *atuRoom;
    NSString *atuPwd;
    NSString *atuIp;
    NSString *atuRemoIp;
    NSInteger atuRemoPort;
    NSInteger isRemote;
    BOOL expand;
}
@property NSInteger atuRemoPort;
@property NSInteger isRemote;
@property BOOL expand;
@property(nonatomic,copy)NSString *atuId;
@property(nonatomic,copy)NSString *atuCode;
@property(nonatomic,copy) NSString *atuName;
@property(nonatomic,copy)NSString *atuRoom;
@property(nonatomic,copy) NSString *atuPwd;
@property(nonatomic,copy)NSString *atuIp;
@property(nonatomic,copy)NSString *atuRemoIp;
-(NSDictionary*)fetchInDictionaryForm;
@end
