//
//  RegisterViewController.h
//  InCloud
//
//  Created by Denis on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol Page2Delegate
-(void)passDict:(NSMutableDictionary *)dicts;
@end
@interface RegisterViewController : UIViewController{
    IBOutlet UITextField *mobilenum;
    IBOutlet UITextField *passwd1;
    IBOutlet UITextField *passwd2;
    IBOutlet UITextField *gencode;
    IBOutlet UIButton *genBtn;
    IBOutlet UIButton *regBtn;
    IBOutlet UIButton *backBtn;
}

@property(nonatomic,retain)IBOutlet UITextField *mobilenum;
@property(nonatomic,retain)IBOutlet UITextField *passwd1;
@property(nonatomic,retain)IBOutlet UITextField *passwd2;
@property(nonatomic,retain)IBOutlet UITextField *gencode;
@property(nonatomic,retain)IBOutlet UIButton *genBtn;
@property(nonatomic,retain)IBOutlet UIButton *backBtn;
@property(nonatomic,retain)IBOutlet UIButton *regBtn;
@property (weak, nonatomic) id delegate;
-(IBAction)RegClick : (id)sender;
-(IBAction)GetgenClick : (id)sender;
-(IBAction)BackClick : (id)sender;
@end
