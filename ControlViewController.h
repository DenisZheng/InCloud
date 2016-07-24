//
//  ControlViewController.h
//  InCloud
//
//  Created by Denis on 15/7/12.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AtuInfo.h"
#import "GCDAsyncUdpSocket.h"
@interface ControlViewController : UIViewController<GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpSocket;
   IBOutlet  UISlider *slider;
   IBOutlet UIView *centerView;
    
    IBOutlet UIButton *coldbtn;
    IBOutlet UIButton *heatbtn;
    IBOutlet UIButton *dehubtn;
    IBOutlet UIButton *fanbtn;
    
    IBOutlet UIButton *fixbtn;
    IBOutlet UIButton *slowbtn;
    IBOutlet UIButton *centerbtn;
    IBOutlet UIButton *strongbtn;
    
    IBOutlet UIButton *upbtn;
    IBOutlet UIButton *downbtn;
     IBOutlet UIButton *powerbtn;
    
    IBOutlet UIImageView *onoffview;
    IBOutlet UIImageView *modeview;
    IBOutlet UIImageView *fanview;
    IBOutlet UIImageView *fixview;
    IBOutlet UIImageView *settmpview;
    IBOutlet UIImageView *curtmpview;
    AtuInfo *atu;
    NSTimer *airtimer;
    
}
@property(nonatomic, strong) IBOutlet UISlider *slider;
@property(nonatomic, strong)  IBOutlet UIView *centerView;
@property(nonatomic, strong)  IBOutlet UIButton *coldbtn;
@property(nonatomic, strong)  IBOutlet UIButton *heatbtn;
@property(nonatomic, strong)  IBOutlet UIButton *dehubtn;
@property(nonatomic, strong)  IBOutlet UIButton *fanbtn;

@property(nonatomic, strong)  IBOutlet UIButton *fixbtn;
@property(nonatomic, strong)  IBOutlet UIButton *slowbtn;
@property(nonatomic, strong)  IBOutlet UIButton *centerbtn;
@property(nonatomic, strong)  IBOutlet UIButton *strongbtn;

@property(nonatomic, strong)  IBOutlet UIButton *upbtn;
@property(nonatomic, strong)  IBOutlet UIButton *downbtn;
@property(nonatomic, strong)  IBOutlet UIButton *powerbtn;

@property(nonatomic, strong)  IBOutlet UIImageView *onoffview;
@property(nonatomic, strong)  IBOutlet UIImageView *modeview;
@property(nonatomic, strong)  IBOutlet UIImageView *fanview;
@property(nonatomic, strong)  IBOutlet UIImageView *fixview;
@property(nonatomic, strong)  IBOutlet UIImageView *settmpview;
@property(nonatomic, strong)  IBOutlet UIImageView *curtmpview;
@property(nonatomic, strong)  AtuInfo *atu;
@property(nonatomic, strong)  NSTimer *airtimer;

- (IBAction)modePressed : (id)sender;
- (IBAction)fanPressed :(id)sender;
- (IBAction)tmpPressed : (id)sender;
- (IBAction)tmpSwip : (id)sender;
- (IBAction)fixPressed : (id)sender;
- (IBAction)powerPressed : (id)sender;
@end
