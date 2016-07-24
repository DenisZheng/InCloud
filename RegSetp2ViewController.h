//
//  RegSetp2ViewController.h
//  InCloud
//
//  Created by vann on 15/7/9.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "GCDAsyncUdpSocket.h"
@interface RegSetp2ViewController : UIViewController<SlideNavigationControllerDelegate,GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *sendUdpSocket;
    NSData *atu;
    IBOutlet UITextField *ssid;
    IBOutlet UITextField *wifipwd;
    IBOutlet UIButton *pairbtn;
    IBOutlet UIButton *cbnbtn;
}
@property(nonatomic,retain)NSData *atu;
@property(nonatomic,retain)IBOutlet UITextField *ssid;
@property(nonatomic,retain)IBOutlet UITextField *wifipwd;
@property(nonatomic,retain)IBOutlet UIButton *pairbtn;
@property(nonatomic,retain)IBOutlet UIButton *cbnbtn;
- (IBAction)pairPressed : (id)sender;
- (IBAction)calPressed : (id)sender;
@end
