//
//  ShareViewController.h
//  InCloud
//
//  Created by Denis on 15/8/1.
//  Copyright (c) 2015年 Denis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "GCDAsyncUdpSocket.h"
@interface ShareViewController : UIViewController<SlideNavigationControllerDelegate,GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpServerSocket;
    GCDAsyncUdpSocket *sendUdpSocket;
    IBOutlet UITextField *sendip;
    IBOutlet UILabel *curip;
    IBOutlet UILabel *sharetitle;
    IBOutlet UIButton *shareclient;
    IBOutlet UIButton *sharesrv;

}
@property (nonatomic,strong)IBOutlet UILabel *curip;
@property (nonatomic,strong)IBOutlet UILabel *sharetitle;
@property (nonatomic,strong)IBOutlet UITextField *sendip;
@property (nonatomic,strong)IBOutlet UIButton *shareclient;
@property (nonatomic,strong)IBOutlet UIButton *sharesrv;
- (IBAction)sendPressed : (id)sender;
- (IBAction)revPressed : (id)sender;
@end
