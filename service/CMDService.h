//
//  CMDService.h
//  InCloud
//
//  Created by Denis on 15/7/8.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaiKinStatus.h"
@interface CMDService : NSObject{
    NSString *atuId;
    NSString *atupwd;
}
@property(nonatomic,retain)NSString *atuId;
@property(nonatomic,retain)NSString *atupwd;
-(NSData *)InCloudCommand:(NSString *)StrCommand;
-(NSData *)FindAtuCommand:(NSString *)AtuId;
-(NSString *)BuildDataString:(DaiKinStatus *)status;
@end
