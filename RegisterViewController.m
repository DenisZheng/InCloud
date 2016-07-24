//
//  RegisterViewController.m
//  InCloud
//
//  Created by Denis on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "RegisterViewController.h"

#import "service/ConfigService.h"
#import "MBProgressHUD.h"
@interface RegisterViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}


@end

@implementation RegisterViewController
@synthesize mobilenum,passwd1,passwd2,gencode,regBtn,genBtn,backBtn,delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)RegClick : (id)sender{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"注册中....";
    HUD.minSize=CGSizeMake(135.f, 135.f);
    
    [HUD showWhileExecuting:@selector(RegisterTask) onTarget:self withObject:nil animated:YES];
				

}

-(void)RegisterTask{
    NSString *usrName = mobilenum.text;
	NSString *pwd1 = passwd1.text;
    NSString *pwd2=passwd2.text;
    NSString *gcode=gencode.text;

	ConfigService *cs=[ConfigService new];
    if ((![pwd1 isEqualToString:pwd2])||([gcode length]==0)) {
        sleep(1);
        __block UIImageView *imageView;
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image=[UIImage imageNamed:@"37x-Checkmark.png"];
            imageView=[[UIImageView  alloc]initWithImage:image];
        });
        HUD.customView=imageView;
        HUD.mode=MBProgressHUDModeCustomView;
        HUD.labelText=@"密码或验证码错误，请重试";
        sleep(2);
        return;
    }else{
          NSInteger regrev=[cs RegUser:usrName Pwd:pwd1 RegCode:gcode];
				if (regrev>0) {
                    //showDialog();
                    sleep(2);
                    __block UIImageView *imageView;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIImage *image=[UIImage imageNamed:@"37x-Checkmark.png"];
                        imageView=[[UIImageView  alloc]initWithImage:image];
                    });
                    HUD.customView=imageView;
                    HUD.mode=MBProgressHUDModeCustomView;
                    HUD.labelText=@"注册成功";
                    sleep(2);
                    //初始化其属性
                    __block NSMutableDictionary *d2=[NSMutableDictionary dictionaryWithCapacity:2];
                    [d2 setObject:usrName forKey:@"USERNAME"];
                    [d2 setObject:pwd1 forKey:@"PASSWD"];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                      [self dismissViewControllerAnimated:YES completion:^{}];
                       [delegate passDict:d2];
                    });
               
                } else {
                    sleep(2);
                    __block UIImageView *imageView;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIImage *image=[UIImage imageNamed:@"37x-Checkmark.png"];
                        imageView=[[UIImageView  alloc]initWithImage:image];
                    });
                    HUD.customView=imageView;
                    HUD.mode=MBProgressHUDModeCustomView;
                    HUD.labelText=@"注册失败，请重试";
                    sleep(2);
                    return;
                }
    }
    
}

-(IBAction)BackClick : (id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)GetgenClick : (id)sender{
    ConfigService *cs=[[ConfigService alloc] init];
    NSString *passcode=[cs GetPassCode];
    [cs GetGenCode:mobilenum.text IdCode:passcode];
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [genBtn setTitle:@"获取" forState:UIControlStateNormal];
                genBtn.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                [genBtn setTitle:[NSString stringWithFormat:@"%@S",strTime] forState:UIControlStateNormal];
                genBtn.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}


-(void)hudWasHidden:(MBProgressHUD *)hud{
    [HUD removeFromSuperview];
    HUD=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
