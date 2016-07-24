//
//  LeftMenuViewController.m
//  InCloud
//
//  Created by Denis on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "ConfigService.h"
@interface LeftMenuViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableView;
    
}

@end

@implementation LeftMenuViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.slideOutAnimationEnabled = YES;
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitView];
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self InitView];
        });
    }];
    // Do any additional setup after loading the view.
}



-(void)InitView{
    float viewWidth=[[UIScreen mainScreen] bounds].size.width/2+90;
    float viewHeight=self.view.frame.size.height;
    tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 191 , viewWidth, viewHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.dataSource=self;
    tableView.delegate=self;
    if (iOS7) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    tableView.rowHeight=([[UIScreen mainScreen] bounds].size.height-191)/6;
    tableView.showsVerticalScrollIndicator=NO;
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(viewWidth-1, 64, 1, viewHeight-64)];
    [self.view addSubview:line];
    line.backgroundColor=[UIColor grayColor];
    
    
    
    
    UIView *titleView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 191)];
    titleView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"homepage_sleep_bg_1"]];;
    
    UIImageView *titleIV=[[UIImageView alloc]initWithFrame:CGRectMake(viewWidth/2-20, 27, 60, 60)];
    titleIV.image=[UIImage imageNamed:@"enter_page_incloud_icon"];
    titleIV.layer.masksToBounds=YES;
    titleIV.layer.cornerRadius=0;
    [titleView addSubview:titleIV];
    ConfigService *cs=[ConfigService new];
    NSString *usrName=[cs GetLoginName];
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth/2-50, 80, 140, 40)];
    [titleView addSubview:titleLabel];
    if (([usrName length]==0)||([usrName isEqualToString:@"admin"])) {
        titleLabel.text=@"你好，欢迎登录";
    }else{
        titleLabel.text=usrName;
    }
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textColor=[UIColor greenColor];
    
    
    UIButton *titleBtn=[[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2-50, 130, 120, 40)];
    [titleBtn setBackgroundImage:[UIImage imageNamed:@"save_normal"] forState:UIControlStateNormal];
    [titleBtn setBackgroundImage:[UIImage imageNamed:@"save_press"] forState:UIControlEventTouchUpInside];
    if (([usrName length]==0)||([usrName isEqualToString:@"admin"])) {
        [titleBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(LogClick) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [titleBtn setTitle:@"注销" forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(ResetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [titleView addSubview:titleBtn];
    [self.view addSubview:titleView];
}

-(void)ResetClick{
      ConfigService *cs=[ConfigService new];
    [cs SetString:@"admin" Password:@"admin" IsCheck:@"0"];
    [self InitView];
}

- (void)LogClick
{
    NSLog(@"dragInside..."); 
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc =[mainStoryboard instantiateViewControllerWithIdentifier: @"LoginViewController"];
    [[SlideNavigationController sharedInstance] switchToViewController:vc 
                                                                     withCompletion:nil];

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellId = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
        
        
    }
    if (indexPath.row==0) {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_area_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"注册空调"];
    }else if (indexPath.row==1) {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_monitoring_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"空调列表"];
    }else if (indexPath.row==2) {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_scence_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"场景"];
    }
    else if (indexPath.row==3) {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_timing_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"定时"];
    }else if (indexPath.row==4) {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_equipment_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"共享"];
    }else {
        cell.imageView.image = [UIImage imageNamed:@"general_title_left_function_page_set_icon"];
        cell.textLabel.text=[NSString stringWithFormat:@"设置"];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    UIViewController *vc ;
    
    switch (indexPath.row)
    {
        case 0:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RegStep1ViewController"];
            break;
            
        case 1:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"HomeViewController"];
            break;
            
        case 2:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SecneViewController"];
            break;
            
        case 3:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SecneViewController"];
            break;
        case 4:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ShareViewController"];
            break;
        case 5:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SecneViewController"];
            break;
    }
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
    
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
