//
//  LoginViewController.h
//  InCloud
//
//  Created by Denis on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
@interface LoginViewController : UIViewController{
    IBOutlet UITextField *mobilenum;
    IBOutlet UITextField *passwd;
    IBOutlet UISwitch *checkpwd;
    IBOutlet UISwitch *autolog;
    IBOutlet UIButton *logbtn;
    IBOutlet UIButton *goRegbtn;
    NSMutableDictionary *dict;
}
@property(nonatomic,retain)IBOutlet UITextField *mobilenum;
@property(nonatomic,retain)IBOutlet UITextField *passwd;
@property(nonatomic,retain)IBOutlet UISwitch *checkpwd;
@property(nonatomic,retain)IBOutlet UISwitch *autolog;
@property(nonatomic,retain)IBOutlet UIButton *logbtn;
@property(nonatomic,retain)IBOutlet UIButton *goRegbtn;
@property(nonatomic,retain)NSMutableDictionary *dict;
-(IBAction)LoginClick : (id)sender;
-(IBAction)RegClick : (id)sender;
@end
