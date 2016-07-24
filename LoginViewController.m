//
//  LoginViewController.m
//  InCloud
//
//  Created by Denis on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "service/ConfigService.h"
#import "AtuInfo.h"
#import "MBProgressHUD.h"
@interface LoginViewController ()<MBProgressHUDDelegate>{
     MBProgressHUD *HUD;
}

@end

@implementation LoginViewController
@synthesize mobilenum,passwd,checkpwd,autolog,logbtn,goRegbtn,dict;

- (void)viewDidLoad {
    [super viewDidLoad];
    dict=nil;
    // Do any additional setup after loading the view.
}

-(IBAction)LoginClick : (id)sender{
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"登录中....";
    HUD.minSize=CGSizeMake(135.f, 135.f);
    
    [HUD showWhileExecuting:@selector(LoginTask) onTarget:self withObject:nil animated:YES];
				
}
-(IBAction)RegClick : (id)sender{
    [self performSegueWithIdentifier:@"regseg" sender:self];
//    RegisterViewController *setPrize = [[RegisterViewController alloc] init];
//
//    [self.navigationController pushViewController:setPrize animated:true];
}

-(void)passDict:(NSMutableDictionary *)dicts{
    NSString *userName=[dicts objectForKey:@"USERNAME"];
    NSString *pwd=[dicts objectForKey:@"PASSWD"];
    mobilenum.text=userName;
    passwd.text=pwd;
}



-(void)LoginTask{
    NSString *usrName = mobilenum.text;
	NSString *pwd = passwd.text;
    NSString *atuId=@"001204011DA0";
	ConfigService *cs=[ConfigService new];
    NSMutableArray *atus=[cs LoadAtusData];
    if ([atus count]>0) {
        NSData *data=[atus objectAtIndex:0];
        AtuInfo *dev=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        atuId=dev.atuId;
    }
	NSString *logrev=[cs RemLogin:usrName Pwd:pwd Serial:atuId];
				if (![logrev hasPrefix:@"Error:"]) {
                    //showDialog();
                    if (checkpwd.on) {
                        [cs SetString:usrName Password:pwd IsCheck:@"1"];
                    } else {
                        [cs SetString:usrName Password:pwd IsCheck:@"0"];
                    }
                    sleep(2);
                    __block UIImageView *imageView;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIImage *image=[UIImage imageNamed:@"37x-Checkmark.png"];
                        imageView=[[UIImageView  alloc]initWithImage:image];
                    });
                    HUD.customView=imageView;
                    HUD.mode=MBProgressHUDModeCustomView;
                    HUD.labelText=@"登录成功";
                    sleep(2);
                    dispatch_sync(dispatch_get_main_queue(), ^{

                    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
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
                    HUD.labelText=@"登录失败，请重试";
                    sleep(2);
                    return;
                }
}

-(void)hudWasHidden:(MBProgressHUD *)hud{
    [HUD removeFromSuperview];
    HUD=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id page2 = segue.destinationViewController;
    [page2 setValue:self forKey:@"delegate"];
}


@end
