//
//  ConfigService.m
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "ConfigService.h"
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "../model/AtuInfo.h"
#import "../MJExtension/MJExtension.h"
@implementation ConfigService



-(NSMutableArray *)LoadAtusData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *savedEncodedData = [defaults objectForKey:@"AtusList"];
    NSMutableArray *atusList = [[NSMutableArray alloc] init];
    if(savedEncodedData == nil)
    {
        return atusList;
    }
    else{
        atusList = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:savedEncodedData];
        return atusList;
    }
}
-(void)SaveAtusData:(NSMutableArray *)atus{
    //save data
    NSData *encodedAtusList = [NSKeyedArchiver archivedDataWithRootObject:atus];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedAtusList forKey:@"AtusList"];
    [defaults synchronize];
}

-(NSString *)AtusToJsonList{
    NSMutableArray *atus=[self LoadAtusData];
  
    NSMutableString *jsonString=[[NSMutableString alloc] init];
    [jsonString appendString:@"["];
    for (int i=0; i<[atus count]; i++) {
    NSData *data=[atus objectAtIndex:i];
    AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    BOOL validJSON = [NSJSONSerialization isValidJSONObject:[dev fetchInDictionaryForm]];
    //BOOL validPlist = [NSPropertyListSerialization propertyList:atus isValidForFormat:NSPropertyListXMLFormat_v1_0];
    NSError *error=nil;
    NSData* jsonData =[NSJSONSerialization dataWithJSONObject:[dev fetchInDictionaryForm]
                                                      options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
        [jsonString appendString:jsonStr];
        if (i<[atus count]-1) {
            [jsonString appendString:@","];
        }
    }
    [jsonString appendString:@"]"];
    NSLog(@"json字典里面的内容为--》%@", jsonString );
    return [jsonString copy];
}

-(NSMutableArray *)JsonListToAtus:(NSString *)json{
    NSData *jsonData=[json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    NSMutableArray *atuarray = [AtuInfo objectArrayWithKeyValuesArray:jsonObject];
    NSMutableArray *atus=[[NSMutableArray alloc] init];
    for (AtuInfo *atu in atuarray) {
        NSData *atudata=[NSKeyedArchiver archivedDataWithRootObject:atu];
        [atus addObject:atudata];
    }
    return atus;
}

#pragma mark -
#pragma mark - 将标准的Json(实体)转换成NSMutableArray (List<class>)
/**
 * 将标准的Json(实体)转换成NSMutableArray
 * @param xml:
 [{"UserID":"ff0f0704","UserName":"fs"},
 {"UserID":"ff0f0704","UserName":"fs"},...]
 * @param class:
 User
 * @return NSMutableArray (List<class>)
 */
-(NSMutableArray*)jsonToArray:(NSString*)json class:(Class)class {
    
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    NSString *patternString = @"\\{.*?\\}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:nil];
    if (regex) {
        NSArray *match = [regex matchesInString:json options:0 range:NSMakeRange(0, [json length])];
        if (match) {
            for (NSTextCheckingResult *result in match) {
                NSString *jsonRow = [json substringWithRange:result.range];
                id object = [[class alloc] init];
                object = [self initWithJsonString:jsonRow object:object];
                [retVal addObject:object];
            }
        }
    }
    return retVal;
}

/**
 * 将传递过来的实体赋值
 * @param xml(忽略实体大小写差异):
 {"UserID":"ff0f0704","UserName":"fs"}
 * @param class:
 User @property userName,userID;
 * @return class
 */
-(id)initWithJsonString:(NSString*)json object:(id)object{
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        NSString *value = [self setJsonProperty:json propertyName:propertyName];
        NSLog(@"name %@,vlue:%@",propertyName,value);
        [object setValue:value forKey:propertyName];
    }
    free(properties);
    
    return object;
}

/**
 * 通过正则将传递过来的实体赋值
 * @param content(忽略实体大小写差异):
 {"UserID":"ff0f0704","UserName":"fs"}
 * @param propertyName:
 userID
 * @return NSString
 ff0f0704
 */
-(NSString*)setJsonProperty:(NSString*)value propertyName:(NSString*)propertyName {
    
    NSString *retVal = @"";
    NSString *patternString = [NSString stringWithFormat:@"(?<=\"%@\":\")*",propertyName];
    // CaseInsensitive:不区分大小写比较
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:nil];
    if (regex) {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:value options:0 range:NSMakeRange(0, [value length])];
        if (firstMatch) {
            retVal = [value substringWithRange:firstMatch.range];
        }
    }
    return retVal;
}



-(void)SetString:(NSString *)user Password:(NSString *)pwd IsCheck:(NSString *)ischk{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:@"UserName"];
     [defaults setObject:pwd forKey:@"Password"];
      [defaults setObject:ischk forKey:@"CheckUp"];
    [defaults synchronize];
}

-(NSString *)GetLoginName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"UserName"];
}
-(NSString *)GetPwd{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"Password"];
}
-(NSString *)GetChekcUp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"CheckUp"];
}

-(NSString *)GetIdCode:(NSString *)passcode{
    NSArray const *pwdarray = @[@"i",@"n",@"C",@"l",@"o",@"u",@"d",@"P",@"a",@"s",@"w",@"r"];
    
    NSString *lastString = @"";
    for (int i=0;i<passcode.length;i++) {
        int intString = [[passcode substringWithRange:NSMakeRange(i,1)] intValue];
        NSString *string = [pwdarray objectAtIndex:intString];
        lastString = [lastString stringByAppendingString:string];
        //string = [NSString stringWithFormat:@"%@%@", lastString, value];

        
    }
    NSLog(@"lastString:%@",lastString);
   // lastString = [NSString stringWithFormat:@"%@", string];
    return lastString;
}

-(NSString *)GetPassCode{
     NSString *retstr=@"";
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    // manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
//    [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
//    //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
//    [manager GET:@"http://www.cseej.com/passcode.php" parameters:nil success: ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *html = operation.responseString;
//        // NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
//        //id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"获取到的html为：%@",html);
//        retstr=[[NSString alloc]initWithFormat:@"%@",[self GetIdCode:html]];
//       // NSLog(@"GET --> %@,%@, %@",html, responseObject, [NSThread currentThread]); //自动返回主线程
//        
//    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"%@", error);
//        
//    }];
//    //dispatch_release(sema);
//     NSLog(@"pwd:%@", retstr);
    NSString *urlstr = [NSString stringWithFormat:@"http://www.cseej.com/passcode.php"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlrequest setHTTPMethod:@"GET"];
     [urlrequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
     [urlrequest addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
     [urlrequest addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    //NSString *bodyStr = [NSString stringWithFormat:@"imei=%@&av=%@",myUUIDStr, AppVersion];
    //NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    //urlrequest.HTTPBody = body;
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest ];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    cookies=requestOperation.response.allHeaderFields[@"Set-Cookie"];
    retstr=[[NSString alloc]initWithFormat:@"%@",[self GetIdCode:requestOperation.responseString]];
    NSLog(@"获取到的html:%@,pwd为：%@",requestOperation.responseString,retstr);
    return retstr;
}

-(NSInteger)GetGenCode:(NSString *)moblienum IdCode:(NSString *)idcode{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        // manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:cookies forHTTPHeaderField:@"Cookie"];
        [manager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
        //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *dict = @{ @"mobilenumber":moblienum, @"id_code":idcode };
        [manager GET:@"http://www.cseej.com/gen_code.php" parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *html = operation.responseString;
            // NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
            //id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
            NSLog(@"获取到的html为：%@",html);
    
        } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                       
        }];
    
    return 0;
}

-(NSInteger)RegUser:(NSString *)moblienum Pwd:(NSString *)passwd RegCode:(NSString *)regcode{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    // manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
//    [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"Cookie" forHTTPHeaderField:cookies];
//    [manager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
//    //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
//    NSDictionary *dict = @{ @"mobilenumber":moblienum, @"pass1":passwd,@"pass2":passwd,@"reg_code":regcode };
//    [manager POST:@"http://www.cseej.com/reg.php" parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *html = operation.responseString;
//        // NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
//        //id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"获取到的html为：%@",html);
//        
//    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"%@", error);
//        
//    }];
    
    
    NSString *urlstr = [NSString stringWithFormat:@"http://www.cseej.com/reg.php"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlrequest setHTTPMethod:@"POST"];
    [urlrequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlrequest addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [urlrequest addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    [urlrequest addValue:cookies forHTTPHeaderField:@"Cookie"];
    NSString *bodyStr = [NSString stringWithFormat:@"mobilenumber=%@&pass1=%@&pass2=%@&reg_code=%@",moblienum, passwd,passwd,regcode];
    NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    urlrequest.HTTPBody = body;
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest ];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSLog(@"获取到的html:%@",requestOperation.responseString);
    NSString *retstr=[[NSString alloc]initWithFormat:@"%@",requestOperation.responseString];
    if ([retstr hasPrefix:@"Register Success!"]) {
        return 1;
    }else{
        return -1;
    }
}
-(NSString *)RemLogin:(NSString *)moblienum Pwd:(NSString *)passwd Serial:(NSString *)serial{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    // manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
//    [manager.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
//    //[manager.requestSerializer setValue:@"Cookie" forHTTPHeaderField:cookies];
//    [manager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
//    //[manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
//    NSDictionary *dict = @{ @"name":moblienum, @"password":passwd,@"serial":serial};
//    [manager POST:@"http://www.cseej.com/login.php" parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *html = operation.responseString;
//        // NSData* data=[html dataUsingEncoding:NSUTF8StringEncoding];
//        //id dict=[NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"获取到的html为：%@",html);
//        
//    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"%@", error);
//        
//    }];

    NSString *urlstr = [NSString stringWithFormat:@"http://www.cseej.com/login.php"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlrequest setHTTPMethod:@"POST"];
    [urlrequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlrequest addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [urlrequest addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    //[urlrequest addValue:cookies forHTTPHeaderField:@"Cookie"];
    NSString *bodyStr = [NSString stringWithFormat:@"name=%@&password=%@&serial=%@",moblienum, passwd,serial];
    NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    urlrequest.HTTPBody = body;
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest ];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSLog(@"获取到的html:%@",requestOperation.responseString);
    NSString *retstr=[[NSString alloc]initWithFormat:@"%@",requestOperation.responseString];
    if (![retstr hasPrefix:@"Error:"]) {
        retstr= [retstr stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        NSArray *array = [retstr componentsSeparatedByString:@";"];
        NSString *remIP=[array objectAtIndex:0];
        return remIP;
    }else{
        retstr=@"";
    }
    return retstr;

}
-(NSString *)RemControl:(NSString *)moblienum Pwd:(NSString *)passwd Serial:(NSString *)serial AirPass:(NSString *)airpass CMD:(NSString *)cmd{
    NSString *urlstr = [NSString stringWithFormat:@"http://www.cseej.com/login.php"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlrequest setHTTPMethod:@"POST"];
    [urlrequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlrequest addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [urlrequest addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    //[urlrequest addValue:cookies forHTTPHeaderField:@"Cookie"];
    NSString *bodyStr = [NSString stringWithFormat:@"name=%@&password=%@&serial=%@&airpass=%@&cmd=%@",moblienum, passwd,serial,airpass,cmd];
    NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    urlrequest.HTTPBody = body;
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest ];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSLog(@"获取到的html:%@",requestOperation.responseString);
    NSString *retstr=[[NSString alloc]initWithFormat:@"%@",requestOperation.responseString];
    if (![retstr hasPrefix:@"Error:"]) {
        retstr= [retstr stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
    }else{
        retstr=@"";
    }
    return retstr;
}
-(NSInteger)ChangPwd:(NSString *)moblienum Pwd:(NSString *)passwd NewPwd:(NSString *)newpass{
    
    NSString *urlstr = [NSString stringWithFormat:@"http://www.cseej.com/changepass.php"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlrequest setHTTPMethod:@"POST"];
    [urlrequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlrequest addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [urlrequest addValue:@"Keep-Alive" forHTTPHeaderField:@"connection"];
    //[urlrequest addValue:cookies forHTTPHeaderField:@"Cookie"];
    NSString *bodyStr = [NSString stringWithFormat:@"name=%@&password=%@&newpass1=%@&newpass2=%@",moblienum, passwd,newpass,newpass];
    NSData *body = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    urlrequest.HTTPBody = body;
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest ];
    requestOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSLog(@"获取到的html:%@",requestOperation.responseString);
    NSString *retstr=[[NSString alloc]initWithFormat:@"%@",requestOperation.responseString];
    if ([retstr hasPrefix:@"Success"]) {
        return 1;
    }else{
        return  -1;
    }
}
@end
