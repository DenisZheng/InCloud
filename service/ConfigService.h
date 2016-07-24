//
//  ConfigService.h
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigService : NSObject{
    NSString *cookies;
}
-(NSMutableArray *)LoadAtusData;
-(void)SaveAtusData:(NSMutableArray *)atus;
-(NSString *)AtusToJsonList;
-(NSMutableArray *)JsonListToAtus:(NSString *)json;
-(NSString *)GetPassCode;
-(NSInteger)GetGenCode:(NSString *)moblienum IdCode:(NSString *)idcode;
-(NSInteger)RegUser:(NSString *)moblienum Pwd:(NSString *)passwd RegCode:(NSString *)regcode;
-(NSString *)RemLogin:(NSString *)moblienum Pwd:(NSString *)passwd Serial:(NSString *)serial;
-(NSString *)RemControl:(NSString *)moblienum Pwd:(NSString *)passwd Serial:(NSString *)serial AirPass:(NSString *)airpass CMD:(NSString *)cmd;
-(NSInteger)ChangPwd:(NSString *)moblienum Pwd:(NSString *)passwd NewPwd:(NSString *)newpass;
-(void)SetString:(NSString *)user Password:(NSString *)pwd IsCheck:(NSString *)ischk;
-(NSString *)GetLoginName;
-(NSString *)GetPwd;
-(NSString *)GetChekcUp;
@end
