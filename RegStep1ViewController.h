//
//  RegStep1ViewController.h
//  InCloud
//
//  Created by vann on 15/7/7.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "GCDAsyncUdpSocket.h"
#import "RegSetp2ViewController.h"

@interface RegStep1ViewController : UIViewController<SlideNavigationControllerDelegate,GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpServerSocket;
    GCDAsyncUdpSocket *sendUdpSocket;
    IBOutlet UITextField *atuId;
    IBOutlet UITextField *atuName;
    IBOutlet UITextField *atuOthername;
    IBOutlet UITextField *roomName;
    IBOutlet UIButton *pairNextBtn;
    IBOutlet UIButton *pairCalBtn;
}
@property(nonatomic,retain)IBOutlet UITextField *atuId;
@property(nonatomic,retain)IBOutlet UITextField *atuName;
@property(nonatomic,retain)IBOutlet UITextField *atuOthername;
@property(nonatomic,retain)IBOutlet UITextField *roomName;
@property(nonatomic,retain)IBOutlet UIButton *pairNextBtn;
@property(nonatomic,retain)IBOutlet UIButton *pairCalBtn;
- (IBAction)nextPressed : (id)sender;
- (IBAction)calPressed : (id)sender;
@end
